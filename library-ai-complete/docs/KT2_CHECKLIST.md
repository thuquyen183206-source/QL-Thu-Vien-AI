# Checklist Bài kiểm tra thường xuyên 2

| # | Tiêu chí | Minh chứng trong project | Trạng thái |
|---|---|---|---|
| 1 | Cấu trúc dự án | frontend/backend/database/config/docs | Đạt |
| 2 | Đăng nhập & phân quyền | `/api/login`, token, `require_role('librarian')`, 2 tài khoản demo | Đạt |
| 3 | CRUD nghiệp vụ chính | Sách, độc giả; mượn/trả; đặt trước | Đạt demo |
| 4 | Tìm kiếm/lọc/sắp xếp | `/api/books?q=&status=&sort=`, độc giả, lọc phiếu mượn | Đạt |
| 5 | Thống kê/báo cáo | `/api/stats`, dashboard và trang Báo cáo | Đạt cơ bản |
| 6 | Giao diện | UI nhất quán, modal, toast, responsive | Đạt |
| 7 | CSDL | MySQL 8.4, schema, FK, seed, transaction mượn/trả | Đạt |
| 8 | Xử lý lỗi | 401/403/404/409/422/500, try/catch frontend/backend | Đạt |
| 9 | Minh chứng AI | `AI_EVIDENCE.md`, `ai_logs`; code đã được kiểm tra/chỉnh sửa | Đạt về hồ sơ minh chứng |
| 10 | Mã nguồn/tài liệu | README, `.env.example`, Docker, docs, gợi ý commit | Đạt |
