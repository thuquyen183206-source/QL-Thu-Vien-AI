# Minh chứng sử dụng AI khi lập trình

> Mục đích: đáp ứng tiêu chí 9. Sinh viên cần bổ sung ảnh chụp hội thoại/prompt thực tế của chính mình trước khi nộp nếu giảng viên yêu cầu ảnh minh chứng.

## Nhật ký 01 – Hoàn thiện cấu trúc và backend
**Prompt:** “Từ giao diện index.html hệ thống quản lý thư viện, hãy tổ chức thành frontend/backend/database/config/docs và bổ sung backend có MySQL.”

**AI hỗ trợ:** đề xuất cấu trúc, REST API, bảng users/books/readers/loans/reservations và Docker Compose.

**Phần sinh viên kiểm tra/chỉnh sửa:** giữ phạm vi chỉ có Thủ thư và Độc giả; loại bỏ Admin; kiểm tra tên chức năng phù hợp đề tài thư viện.

## Nhật ký 02 – Đăng nhập và phân quyền
**Prompt:** “Bổ sung đăng nhập và phân quyền Thủ thư/Độc giả, không cho Độc giả gọi API quản lý.”

**AI hỗ trợ:** token đăng nhập, middleware/hàm kiểm tra vai trò, mã lỗi 401/403.

**Phần sinh viên kiểm tra/chỉnh sửa:** thử đăng nhập bằng 2 tài khoản demo; thử Độc giả truy cập chức năng Thủ thư và xác nhận bị chặn.

## Nhật ký 03 – CRUD và xử lý lỗi
**Prompt:** “Hoàn thiện CRUD sách, độc giả, mượn trả, đặt trước và xử lý input sai.”

**AI hỗ trợ:** API CRUD, transaction mượn/trả, validation và thông báo lỗi.

**Phần sinh viên kiểm tra/chỉnh sửa:** không cho xóa sách đang mượn; không cho xóa độc giả còn sách; kiểm tra số lượng sách trước khi mượn.

## Minh chứng AI trong hệ thống
Endpoint `/api/ai` đọc danh mục sách từ MySQL, tạo phản hồi demo có kiểm soát và ghi prompt/phản hồi vào bảng `ai_logs`. Đây là chức năng AI demo của đề tài; không thay thế minh chứng sử dụng AI khi lập trình ở trên.

## Nhật ký review và cải thiện

| Phát hiện | File đã chỉnh | Cải thiện |
|---|---|---|
| Context model chưa có giới hạn kích thước rõ ràng | `backend/src/ai.php` | Thêm `AI_MAX_CONTEXT_CHARS` và trả lỗi 413 khi vượt giới hạn |
| Model có thể trả `sources` ngoài dữ liệu cho phép | `backend/src/ai.php` | Whitelist ba nhóm nguồn trước khi trả về UI |
| Timeout/429/JSON lỗi làm gián đoạn trợ lý | `backend/src/ai.php`, `backend/public/index.php` | Fallback nội bộ kèm cảnh báo rõ ràng |
| CORS mở toàn bộ origin | `backend/public/index.php`, `docker-compose.yml` | Giới hạn theo `CORS_ORIGIN` |
| Có thể gửi nhiều request AI cùng lúc | `frontend/index.html` | Khóa nút gửi trong lúc chờ response |

Các phát hiện trên được kiểm tra lại bằng lint/kiểm thử API trước khi nộp. Ảnh chụp hoặc transcript công cụ AI dùng trong quá trình lập trình cần được sinh từ phiên làm việc thực tế của sinh viên và đính kèm riêng nếu giảng viên yêu cầu.
