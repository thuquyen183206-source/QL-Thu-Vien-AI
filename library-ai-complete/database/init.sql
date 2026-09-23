CREATE DATABASE IF NOT EXISTS library_ai CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE library_ai;
SET NAMES utf8mb4;
CREATE TABLE readers(id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(120) NOT NULL,code VARCHAR(30) UNIQUE NOT NULL,type VARCHAR(40) NOT NULL,joined DATE NOT NULL,borrowed INT NOT NULL DEFAULT 0,status ENUM('active','locked') NOT NULL DEFAULT 'active');
CREATE TABLE users(id INT AUTO_INCREMENT PRIMARY KEY,name VARCHAR(120) NOT NULL,email VARCHAR(160) UNIQUE NOT NULL,password_hash VARCHAR(255) NOT NULL,role ENUM('librarian','reader') NOT NULL,reader_id INT NULL,active TINYINT(1) NOT NULL DEFAULT 1,FOREIGN KEY(reader_id) REFERENCES readers(id) ON DELETE SET NULL);
CREATE TABLE api_tokens(id BIGINT AUTO_INCREMENT PRIMARY KEY,user_id INT NOT NULL,token_hash CHAR(64) UNIQUE NOT NULL,expires_at DATETIME NOT NULL,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);
CREATE TABLE books(id INT AUTO_INCREMENT PRIMARY KEY,title VARCHAR(200) NOT NULL,author VARCHAR(160) NOT NULL,category VARCHAR(100) NOT NULL,year INT NOT NULL,quantity INT NOT NULL,available INT NOT NULL,description TEXT NULL);
CREATE TABLE loans(id INT AUTO_INCREMENT PRIMARY KEY,reader_id INT NOT NULL,book_id INT NOT NULL,borrowed DATE NOT NULL,due DATE NOT NULL,returned_at DATE NULL,status ENUM('open','overdue','returned') NOT NULL DEFAULT 'open',FOREIGN KEY(reader_id) REFERENCES readers(id),FOREIGN KEY(book_id) REFERENCES books(id));
CREATE TABLE reservations(id INT AUTO_INCREMENT PRIMARY KEY,reader_id INT NOT NULL,book_id INT NOT NULL,request_date DATE NOT NULL,position INT NOT NULL,status ENUM('pending','fulfilled','cancelled') NOT NULL DEFAULT 'pending',FOREIGN KEY(reader_id) REFERENCES readers(id),FOREIGN KEY(book_id) REFERENCES books(id));
CREATE TABLE ai_logs(id BIGINT AUTO_INCREMENT PRIMARY KEY,user_id INT NOT NULL,prompt TEXT NOT NULL,response TEXT NOT NULL,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id));
INSERT INTO readers(name,code,type,joined,borrowed,status) VALUES
('Nguyễn Minh Anh','DG-1024','Sinh viên','2025-02-12',1,'active'),('Trần Hoàng Nam','DG-0871','Giảng viên','2024-09-08',1,'active'),('Lê Thu Hà','DG-1108','Sinh viên','2025-04-18',1,'active'),('Phạm Quốc Bảo','DG-0652','Khách','2023-06-21',0,'locked');
INSERT INTO users(name,email,password_hash,role,reader_id) VALUES
('Nông Việt','thuthu@library.local','$2y$12$wQf5avAQsYuwAX0D79VNIeQ7cv7s22c14OrOhabldpmQnHFAT7KIy','librarian',NULL),
('Nguyễn Minh Anh','docgia@library.local','$2y$12$1yAWJJlhDhUqYXPmqpxagOwPw21IiyZgF2/rn99trnO/HgLFGnaGa','reader',1);
INSERT INTO books(title,author,category,year,quantity,available,description) VALUES
('Nhà giả kim','Paulo Coelho','Văn học',1988,8,7,'Hành trình theo đuổi kho báu và lắng nghe tiếng gọi nội tâm.'),
('Clean Code','Robert C. Martin','Công nghệ',2008,5,4,'Những nguyên tắc viết mã nguồn sạch và dễ bảo trì.'),
('Design of Everyday Things','Don Norman','Thiết kế',2013,4,4,'Tư duy thiết kế lấy con người làm trung tâm.'),
('Sapiens','Yuval Noah Harari','Lịch sử',2011,6,5,'Lược sử loài người từ thời tiền sử đến hiện đại.'),
('Tư duy nhanh và chậm','Daniel Kahneman','Kỹ năng',2011,7,7,'Hai hệ thống tư duy và những thiên kiến trong quyết định.');
INSERT INTO books(title,author,category,year,quantity,available,description) VALUES
('Vũ trụ trong vỏ hạt dẻ','Stephen Hawking','Khoa học',2001,4,4,'Khám phá những câu hỏi lớn về không gian, thời gian và vũ trụ.'),
('Gen: Lịch sử và tương lai của nhân loại','Siddhartha Mukherjee','Khoa học',2016,3,3,'Câu chuyện về di truyền học và ảnh hưởng của nó đến con người.'),
('English Grammar in Use','Raymond Murphy','Ngoại ngữ',2019,5,5,'Tài liệu thực hành ngữ pháp tiếng Anh theo từng chủ đề.'),
('Dế Mèn phiêu lưu ký','Tô Hoài','Thiếu nhi',1941,6,6,'Cuộc phiêu lưu giàu bài học về tình bạn và sự trưởng thành.'),
('Hoàng tử bé','Antoine de Saint-Exupéry','Thiếu nhi',1943,5,5,'Câu chuyện giàu tưởng tượng về tình yêu, tình bạn và trách nhiệm.'),
('Mắt biếc','Nguyễn Nhật Ánh','Truyện tranh',1990,4,4,'Câu chuyện tuổi học trò về tình yêu trong sáng và những kỷ niệm đẹp.'),
('Sức mạnh của hiện tại','Eckhart Tolle','Sức khỏe',1997,4,4,'Những thực hành giúp sống tỉnh thức và cân bằng trong hiện tại.'),
('Why We Sleep','Matthew Walker','Sức khỏe',2017,3,3,'Giải thích vai trò của giấc ngủ đối với sức khỏe và trí nhớ.'),
('Into the Wild','Jon Krakauer','Du lịch',1996,3,3,'Hành trình khám phá thiên nhiên và giới hạn của con người.'),
('Nhà giả kim và hành trình tâm linh','Nguyễn Hiến Lê','Tôn giáo',2008,2,2,'Những suy ngẫm về niềm tin, mục đích sống và hành trình nội tâm.'),
('Tâm lý học đám đông','Gustave Le Bon','Xã hội học',1895,3,3,'Phân tích hành vi và tâm lý của con người trong cộng đồng.'),
('Lược sử triết học','Will Durant','Triết học',1926,3,3,'Tổng quan các tư tưởng và triết gia quan trọng trong lịch sử.');
INSERT INTO loans(reader_id,book_id,borrowed,due,status) VALUES (1,1,'2026-08-26','2026-09-09','open'),(2,2,'2026-08-18','2026-09-01','open'),(3,4,'2026-08-05','2026-08-19','overdue');
INSERT INTO reservations(reader_id,book_id,request_date,position,status) VALUES (3,2,'2026-08-25',1,'pending');
