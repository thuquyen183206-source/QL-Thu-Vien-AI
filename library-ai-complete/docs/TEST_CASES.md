# Test cases demo

| ID | Thao tác | Kết quả mong đợi |
|---|---|---|
| TC01 | Đăng nhập Thủ thư đúng | Vào Tổng quan, thấy menu quản lý |
| TC02 | Đăng nhập sai mật khẩu | 401, hiện thông báo, không crash |
| TC03 | Đăng nhập Độc giả | Vào Cổng độc giả, ẩn Độc giả/Báo cáo |
| TC04 | Độc giả gọi API POST /books | 403 Không có quyền |
| TC05 | Thủ thư thêm sách hợp lệ | Sách lưu MySQL và xuất hiện trên bảng |
| TC06 | Thêm sách thiếu tên | 422, hiện lỗi |
| TC07 | Tìm “Clean” | Chỉ hiện sách phù hợp |
| TC08 | Lập phiếu mượn khi còn sách | Tạo loan, available giảm 1, borrowed tăng 1 |
| TC09 | Trả sách | Loan returned, available tăng 1 |
| TC10 | Xóa sách đang mượn | 409, không xóa |
| TC11 | Tạo/hủy đặt trước | Dữ liệu cập nhật trong MySQL |
| TC12 | Gửi câu hỏi Trợ lý AI | Có phản hồi và bản ghi trong `ai_logs` |
| TC13 | Gửi prompt rỗng | 422, không gọi model |
| TC14 | Prompt dài hơn giới hạn | 422, yêu cầu rút gọn |
| TC15 | Gọi AI khi chưa đăng nhập | 401 |
| TC16 | Độc giả gọi AI và `/loans` | 200 nhưng chỉ thấy dữ liệu của chính mình |
| TC17 | Model timeout/429/JSON sai | Fallback nội bộ, có cảnh báo và nguồn hợp lệ |
| TC18 | Bấm Gửi nhiều lần liên tiếp | Chỉ có một request đang chạy |
