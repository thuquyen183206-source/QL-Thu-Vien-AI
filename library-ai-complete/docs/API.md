# API chính
- `POST /api/login`, `POST /api/logout`, `GET /api/me`
- `GET /api/stats`
- `GET/POST /api/books`, `PUT/DELETE /api/books/{id}`
- `GET/POST /api/readers`, `PUT/DELETE /api/readers/{id}`
- `GET/POST /api/loans`, `PUT /api/loans/{id}/return`
- `GET/POST /api/reservations`, `DELETE /api/reservations/{id}`
- `POST /api/ai`

Quyền quản lý sách, độc giả và mượn/trả được kiểm tra ở backend. Độc giả chỉ đọc dữ liệu phù hợp và tự tạo/hủy đặt trước của mình.
