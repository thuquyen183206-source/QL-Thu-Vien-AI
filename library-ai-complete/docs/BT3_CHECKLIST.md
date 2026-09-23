# Bài kiểm tra thường xuyên 3 - Checklist

| # | Tiêu chí | Minh chứng trong project | Trạng thái |
|---|---|---|---|
| 1 | Tích hợp AI vào nghiệp vụ | Trợ lý thư viện tại `POST /api/ai`, tìm sách/gợi ý từ danh mục | Đạt |
| 2 | Kết nối model và bảo vệ key | `backend/src/ai.php` hỗ trợ OpenAI-compatible/Gemini; key đọc từ biến môi trường Docker, không nằm trong source | Đạt; cần chạy thêm với key thật nếu giảng viên yêu cầu |
| 3 | Prompt có hệ thống | `backend/prompts/system.txt` và `user.txt`, JSON output, giới hạn dữ liệu/catalog context | Đạt |
| 4 | Tối ưu prompt | `docs/PROMPT_EXPERIMENTS.md` ghi 3 vòng, câu hỏi kiểm thử, tiêu chí quan sát và cải tiến | Đạt; bổ sung log model thật nếu có |
| 5 | Dữ liệu hệ thống và quyền | `ai_catalog_context()` lấy sách từ MySQL; độc giả chỉ nhận `my_loans` của chính mình; endpoint yêu cầu đăng nhập | Đạt |
| 6 | Hiển thị kết quả | Frontend hiển thị câu trả lời, nguồn, model/fallback và cảnh báo lỗi | Đạt |
| 7 | Lỗi và giới hạn | Timeout, 429, response rỗng/sai JSON, HTTP model lỗi, prompt/context quá dài và fallback local | Đạt |
| 8 | Kiểm thử | `tests/api-test.ps1` kiểm tra đúng, sai, biên, 401/403 và AI | Đạt khi chạy script |
| 9 | Review bằng AI | `docs/AI_EVIDENCE.md` có nhật ký review, phát hiện, file sửa và kết quả mong đợi | Đạt hồ sơ; ảnh/transcript phải là minh chứng phiên làm việc thực tế |
| 10 | UX tích hợp | AI nằm trong menu hệ thống, dùng cùng auth, có câu hỏi gợi ý và không thay thế thao tác quản lý | Đạt |

## Cách xác nhận trước khi nộp

1. Chạy `docker compose up --build -d`.
2. Nếu dùng model thật, tạo file `.env` cục bộ từ `.env.example` và thêm `AI_PROVIDER`/`AI_API_KEY`; không commit file này.
3. Chạy `pwsh -File tests/api-test.ps1` hoặc PowerShell 5.1 bằng `powershell -File tests/api-test.ps1`.
4. Chụp màn hình đăng nhập, trợ lý AI, kết quả có nguồn và log kiểm thử nếu cần minh chứng trực quan.
