# Nhật ký tối ưu prompt AI

Các vòng dưới đây được thực hiện trên cùng danh mục seed và cùng nhóm câu hỏi: tìm sách theo thể loại, kiểm tra tình trạng, tóm tắt sách không có trong catalog.

## Vòng 1 - Prompt tự do

- **Thiết kế:** chỉ yêu cầu trợ lý trả lời dựa trên danh mục.
- **Kết quả:** câu trả lời dễ hiểu nhưng có thể thiếu nguồn và chưa thống nhất định dạng; câu hỏi ngoài phạm vi chưa luôn nói rõ giới hạn.
- **Cải tiến:** thêm system prompt, quy định chỉ dùng context và yêu cầu JSON gồm `answer`, `sources`.

## Vòng 2 - Ràng buộc dữ liệu và output

- **Thiết kế:** system prompt cấm bịa sách/mã sách/tình trạng; user prompt truyền `QUESTION` và `CONTEXT_JSON`; bắt buộc JSON.
- **Kết quả:** giảm câu trả lời ngoài catalog và frontend có thể hiển thị nguồn. Một số response model vẫn có thể trả JSON lỗi hoặc quá dài.
- **Cải tiến:** thêm kiểm tra parse JSON, kiểm tra trường `answer`, giới hạn `max_tokens`, timeout và giới hạn độ dài câu hỏi.

## Vòng 3 - Phân quyền và fallback

- **Thiết kế:** xây context từ MySQL sau khi xác thực; độc giả chỉ nhận lịch sử mượn của chính mình; thủ thư mới nhận thống kê tổng quan; có local fallback khi chưa cấu hình API key.
- **Kết quả:** chức năng chạy được trong môi trường demo không cần khóa thật, không lộ dữ liệu người khác và có thể truy vết nguồn.
- **Cải tiến cuối:** ghi prompt/response vào `ai_logs`, trả `mode`, hiển thị cảnh báo fallback trên UI, xử lý 429/5xx/timeout riêng.

## Kết luận

Thiết kế vòng 3 được giữ trong `backend/prompts/system.txt`, `backend/prompts/user.txt` và `backend/src/ai.php`. Khi chấm với model thật, cần lưu ảnh hoặc log của ba câu hỏi đại diện và kết quả thực tế để bổ sung minh chứng cá nhân.

## Bảng kiểm chứng lặp lại

| Vòng | Câu hỏi kiểm thử | Tiêu chí quan sát | Kết quả ghi nhận trong bản demo |
|---|---|---|---|
| 1 | `Tìm sách công nghệ` | Có trả lời tự do, chưa bắt buộc nguồn | Có thể trả lời nhưng khó kiểm tra tính nhất quán |
| 2 | `Tìm sách công nghệ` | JSON hợp lệ, có `answer` và `sources` | Backend parse JSON, từ chối response rỗng/sai schema |
| 3 | `Lịch sử mượn của tôi là gì?` | Context đã lọc theo user, không lộ dữ liệu khác | Reader chỉ nhận `my_loans` của chính mình; nguồn bị whitelist |

Khi dùng model thật, chạy lại ba câu hỏi trên và lưu model, thời gian, response thực tế cùng log `tests/api-test.ps1`. Khi không có API key, vòng 3 được kiểm chứng bằng `local-fallback`; hệ thống hiển thị rõ chế độ này trên giao diện.
