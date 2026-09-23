# Hệ thống quản lý thư viện có tích hợp AI – Bài kiểm tra thường xuyên 2

Bản hoàn chỉnh demo theo 10 tiêu chí của đề. Hệ thống **chỉ có 2 vai trò: Thủ thư và Độc giả, không có Admin**.

## 1. Cấu trúc
- `frontend/`: giao diện HTML/CSS/JS giữ phong cách từ bản gốc.
- `backend/`: REST API PHP, xác thực Bearer token, kiểm tra vai trò ở server.
- `database/`: MySQL schema + dữ liệu mẫu.
- `config/`: ghi chú cấu hình.
- `docs/`: checklist, API, test case, minh chứng AI.

## 2. Chạy nhanh bằng Docker Desktop
Yêu cầu: Docker Desktop đang chạy.

```bash
docker compose up --build -d
```

Mở: `http://localhost:8090`

API health: `http://localhost:8000/api/health`

MySQL host từ Windows: `localhost:3307`, database `library_ai`, user `library_user`, password `library_pass`.

> Nếu đã chạy bản cũ và muốn nạp lại toàn bộ dữ liệu mẫu: `docker compose down -v` rồi `docker compose up --build -d`.

Nếu danh mục từ volume cũ hiển thị dấu `?` thay cho tiếng Việt, chạy migration UTF-8:

```bash
docker cp database/fix-vietnamese-books.sql library-ai-complete-db-1:/tmp/fix-vietnamese-books.sql
docker compose exec db sh -c "mysql --default-character-set=utf8mb4 -ulibrary_user -plibrary_pass library_ai < /tmp/fix-vietnamese-books.sql"
```

Để bổ sung danh mục mở rộng cho database đang chạy:

```bash
docker cp database/add-more-books.sql library-ai-complete-db-1:/tmp/add-more-books.sql
docker compose exec db sh -c "mysql --default-character-set=utf8mb4 -ulibrary_user -plibrary_pass library_ai < /tmp/add-more-books.sql"
```

## 3. Tài khoản demo
- Thủ thư: `thuthu@library.local` / `ThuThu@123`
- Độc giả: `docgia@library.local` / `DocGia@123`

Mật khẩu trong CSDL được lưu dưới dạng bcrypt hash, không lưu plaintext.

## 4. Chức năng đã có
- Đăng nhập/đăng xuất và xác thực token.
- Phân quyền Thủ thư/Độc giả ở backend (403 nếu sai quyền).
- CRUD sách; CRUD độc giả; mượn/trả; đặt trước/hủy.
- Tìm kiếm/lọc sách và độc giả; lọc trạng thái phiếu mượn.
- Dashboard/báo cáo cơ bản.
- MySQL + dữ liệu seed demo.
- Validation, xử lý 401/403/404/409/422/500.
- Trợ lý thư viện demo lấy dữ liệu sách từ MySQL và ghi `ai_logs`.
- Danh mục gồm 37 đầu sách thuộc 18 thể loại: Văn học, Công nghệ, Thiết kế, Lịch sử, Kỹ năng, Tâm lý, Kinh doanh, Phát triển bản thân, Tâm linh, Khoa học, Ngoại ngữ, Thiếu nhi, Truyện tranh, Sức khỏe, Du lịch, Tôn giáo, Xã hội học và Triết học.
- Tài liệu minh chứng AI, test case và hướng dẫn chạy.

## 5. Lưu ý về AI
Endpoint `/api/ai` có hai chế độ: `local` để chạy demo không cần khóa, và `openai`/provider tương thích OpenAI hoặc `gemini` khi cấu hình biến môi trường. Khóa API chỉ đọc từ môi trường, không ghi vào source. Khi model timeout, rate limit hoặc trả sai JSON, hệ thống tự chuyển sang `local-fallback` và hiển thị cảnh báo.

Prompt nằm ngoài code tại `backend/prompts/system.txt` và `backend/prompts/user.txt`. Các vòng thử nghiệm, giới hạn và minh chứng review nằm trong `docs/PROMPT_EXPERIMENTS.md` và `docs/AI_EVIDENCE.md`.

## 6. Git commit gợi ý
```bash
git init
git add .
git commit -m "chore: initialize library project structure"
git commit -m "feat: add authentication and role authorization"
git commit -m "feat: complete library CRUD search reports and mysql"
git commit -m "docs: add AI evidence tests and run guide"
```
