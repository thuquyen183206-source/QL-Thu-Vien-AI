<?php

function ai_prompt(string $name): string
{
    $path = '/var/www/prompts/'.$name;
    $prompt = file_get_contents($path);
    if ($prompt === false) {
        throw new RuntimeException('Không tải được prompt AI');
    }
    return trim($prompt);
}

function ai_config(): array
{
    return [
        'provider' => strtolower(trim(getenv('AI_PROVIDER') ?: 'local')),
        'base_url' => rtrim(trim(getenv('AI_BASE_URL') ?: 'https://api.openai.com/v1'), '/'),
        'model' => trim(getenv('AI_MODEL') ?: 'gpt-4o-mini'),
        'api_key' => trim(getenv('AI_API_KEY') ?: ''),
        'timeout' => max(3, min(30, (int)(getenv('AI_TIMEOUT_SECONDS') ?: 12))),
        'max_prompt_chars' => max(1000, min(12000, (int)(getenv('AI_MAX_PROMPT_CHARS') ?: 8000))),
        'max_context_chars' => max(4000, min(30000, (int)(getenv('AI_MAX_CONTEXT_CHARS') ?: 24000))),
    ];
}

function ai_context_json(array $context, int $maxChars): string
{
    $json = json_encode($context, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if ($json === false) {
        throw new RuntimeException('Không thể chuẩn bị dữ liệu cho model', 500);
    }
    if (mb_strlen($json) > $maxChars) {
        throw new RuntimeException('Dữ liệu thư viện cho AI quá dài, vui lòng thử câu hỏi cụ thể hơn', 413);
    }
    return $json;
}

function ai_sources(array $sources): array
{
    $allowed = ['Danh mục sách', 'Lịch sử mượn của tôi', 'Tổng quan thư viện'];
    return array_values(array_unique(array_filter($sources, static fn($source) => is_string($source) && in_array($source, $allowed, true))));
}

function ai_catalog_context(array $user): array
{
    $books = db()->query('SELECT title,author,category,year,available,quantity,description FROM books ORDER BY title LIMIT 80')->fetchAll();
    $context = ['catalog' => $books];
    if ($user['role'] === 'reader' && $user['reader_id']) {
        $loan = db()->prepare("SELECT b.title,l.borrowed,l.due,l.status FROM loans l JOIN books b ON b.id=l.book_id WHERE l.reader_id=? ORDER BY l.id DESC LIMIT 20");
        $loan->execute([(int)$user['reader_id']]);
        $context['my_loans'] = $loan->fetchAll();
    }
    if ($user['role'] === 'librarian') {
        $context['library_summary'] = [
            'borrowed' => (int)db()->query("SELECT COUNT(*) FROM loans WHERE status IN ('open','overdue')")->fetchColumn(),
            'overdue' => (int)db()->query("SELECT COUNT(*) FROM loans WHERE status='overdue'")->fetchColumn(),
        ];
    }
    return $context;
}

function ai_search_books(string $question, array $books): array
{
    $normalized = static function (string $value): array {
        $value = mb_strtolower($value);
        $value = preg_replace('/[^\p{L}\p{N}]+/u', ' ', $value) ?? '';
        $stopWords = ['cho', 'toi', 'tôi', 'muon', 'muốn', 'tim', 'tìm', 'sach', 'sách', 've', 'về', 'cua', 'của', 'co', 'có', 'khong', 'không', 'hay', 'la', 'là', 'mot', 'một', 'quyen', 'quyển', 'cuon', 'cuốn', 'tom', 'tóm', 'tat', 'tắt', 'goi', 'gợi', 'y', 'ý', 'nhe', 'nhẹ', 'dang', 'đang', 'con', 'còn', 'nao', 'nào', 'the', 'thể', 'loai', 'loại'];
        return array_values(array_unique(array_filter(explode(' ', trim($value)), static fn($word) => mb_strlen($word) > 1 && !in_array($word, $stopWords, true))));
    };
    $queryWords = $normalized($question);
    $ranked = [];
    foreach ($books as $book) {
        $titleWords = $normalized($book['title']);
        $authorWords = $normalized($book['author']);
        $categoryWords = $normalized($book['category']);
        $descriptionWords = $normalized((string)($book['description'] ?? ''));
        $score = 0;
        foreach ($queryWords as $word) {
            if (in_array($word, $titleWords, true)) $score += 5;
            elseif (in_array($word, $authorWords, true)) $score += 3;
            elseif (in_array($word, $categoryWords, true)) $score += 2;
            elseif (in_array($word, $descriptionWords, true)) $score += 1;
        }
        if ($score > 0) {
            $book['_score'] = $score;
            $ranked[] = $book;
        }
    }
    usort($ranked, static fn($left, $right) => $right['_score'] <=> $left['_score']);
    return array_map(static function ($book) {
        unset($book['_score']);
        return $book;
    }, array_slice($ranked, 0, 5));
}

function ai_local_answer(string $question, array $context): string
{
    $query = mb_strtolower(trim($question));
    $books = $context['catalog'];
    $matches = ai_search_books($question, $books);
    if ($matches) {
        return implode(' ', array_map(static fn($book) => $book['title'].' - '.$book['author'].'. '.($book['description'] ?: 'Chưa có mô tả.').' Tình trạng: '.((int)$book['available'] > 0 ? 'còn sách' : 'đang hết bản sẵn sàng').'.', $matches));
    }
    $available = array_values(array_filter($books, static fn($book) => (int)$book['available'] > 0));
    if (str_contains($query, 'gợi ý') || str_contains($query, 'đọc') || str_contains($query, 'recommend')) {
        return 'Mình gợi ý: '.implode('; ', array_map(static fn($book) => $book['title'].' ('.$book['author'].')', array_slice($available, 0, 5))).'.';
    }
    return 'Mình có thể tìm theo tên sách, tác giả hoặc thể loại; kiểm tra tình trạng sách; và gợi ý sách từ danh mục hiện có.';
}

function ai_model_answer(string $question, array $context, array $config): array
{
    $contextJson = ai_context_json($context, $config['max_context_chars']);
    $payload = [
        'model' => $config['model'],
        'temperature' => 0.2,
        'max_tokens' => 500,
        'response_format' => ['type' => 'json_object'],
        'messages' => [
            ['role' => 'system', 'content' => ai_prompt('system.txt')],
            ['role' => 'user', 'content' => str_replace(['{{QUESTION}}', '{{CONTEXT_JSON}}'], [$question, $contextJson], ai_prompt('user.txt'))],
        ],
    ];
    $ch = curl_init($config['base_url'].'/chat/completions');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Bearer '.$config['api_key'], 'Content-Type: application/json'],
        CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
        CURLOPT_TIMEOUT => $config['timeout'],
    ]);
    $raw = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($raw === false || $curlError) {
        throw new RuntimeException('Model không phản hồi trong thời gian cho phép', 504);
    }
    if ($httpCode === 429) {
        throw new RuntimeException('Model đang giới hạn lượt gọi, vui lòng thử lại sau', 429);
    }
    if ($httpCode >= 400) {
        throw new RuntimeException('Model từ chối yêu cầu (HTTP '.$httpCode.')', 502);
    }
    $response = json_decode($raw, true);
    $content = $response['choices'][0]['message']['content'] ?? '';
    if (!is_string($content) || trim($content) === '') {
        throw new RuntimeException('Model trả về dữ liệu rỗng', 502);
    }
    $answer = json_decode($content, true);
    if (!is_array($answer) || !is_string($answer['answer'] ?? null) || trim($answer['answer']) === '') {
        throw new RuntimeException('Model trả về sai định dạng JSON', 502);
    }
    return ['answer' => trim($answer['answer']), 'sources' => ai_sources($answer['sources'] ?? [])];
}

function ai_gemini_answer(string $question, array $context, array $config): array
{
    $userPrompt = str_replace(['{{QUESTION}}', '{{CONTEXT_JSON}}'], [$question, ai_context_json($context, $config['max_context_chars'])], ai_prompt('user.txt'));
    $payload = [
        'systemInstruction' => ['parts' => [['text' => ai_prompt('system.txt')]]],
        'contents' => [['role' => 'user', 'parts' => [['text' => $userPrompt]]]],
        'generationConfig' => [
            'temperature' => 0.2,
            'maxOutputTokens' => 500,
            'responseMimeType' => 'application/json',
        ],
    ];
    $url = 'https://generativelanguage.googleapis.com/v1beta/models/'.rawurlencode($config['model']).':generateContent?key='.rawurlencode($config['api_key']);
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE),
        CURLOPT_TIMEOUT => $config['timeout'],
    ]);
    $raw = curl_exec($ch);
    $curlError = curl_error($ch);
    $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    if ($raw === false || $curlError) {
        throw new RuntimeException('Gemini không phản hồi trong thời gian cho phép', 504);
    }
    if ($httpCode === 429) {
        throw new RuntimeException('Gemini đang giới hạn lượt gọi, vui lòng thử lại sau', 429);
    }
    if ($httpCode >= 400) {
        throw new RuntimeException('Gemini từ chối yêu cầu (HTTP '.$httpCode.')', 502);
    }
    $response = json_decode($raw, true);
    $content = $response['candidates'][0]['content']['parts'][0]['text'] ?? '';
    if (!is_string($content) || trim($content) === '') {
        throw new RuntimeException('Gemini trả về dữ liệu rỗng', 502);
    }
    $answer = json_decode(trim($content), true);
    if (!is_array($answer) || !is_string($answer['answer'] ?? null) || trim($answer['answer']) === '') {
        throw new RuntimeException('Gemini trả về sai định dạng JSON', 502);
    }
    return ['answer' => trim($answer['answer']), 'sources' => ai_sources($answer['sources'] ?? [])];
}

function ai_answer(string $question, array $user): array
{
    $config = ai_config();
    $question = trim($question);
    if ($question === '') {
        throw new InvalidArgumentException('Vui lòng nhập câu hỏi', 422);
    }
    if (mb_strlen($question) > $config['max_prompt_chars']) {
        throw new InvalidArgumentException('Câu hỏi quá dài, vui lòng rút gọn dưới '.$config['max_prompt_chars'].' ký tự', 422);
    }
    $context = ai_catalog_context($user);
    try {
        if ($config['provider'] === 'gemini' && $config['api_key'] !== '') {
            $result = ai_gemini_answer($question, $context, $config);
            $result['mode'] = 'gemini/'.$config['model'];
            return $result;
        }
        if ($config['provider'] !== 'local' && $config['api_key'] !== '') {
            $result = ai_model_answer($question, $context, $config);
            $result['mode'] = $config['provider'].'/'.$config['model'];
            return $result;
        }
    } catch (Throwable $error) {
        return [
            'answer' => ai_local_answer($question, $context),
            'sources' => ['Danh mục sách'],
            'mode' => 'local-fallback',
            'warning' => 'Model tạm thời không khả dụng; hệ thống đã dùng dữ liệu nội bộ để trả lời.',
        ];
    }
    return ['answer' => ai_local_answer($question, $context), 'sources' => ['Danh mục sách'], 'mode' => 'local-fallback'];
}
