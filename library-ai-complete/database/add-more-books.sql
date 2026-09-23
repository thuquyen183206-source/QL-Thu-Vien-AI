USE library_ai;
SET NAMES utf8mb4;

INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Vũ trụ trong vỏ hạt dẻ','Stephen Hawking','Khoa học',2001,4,4,'Khám phá những câu hỏi lớn về không gian, thời gian và vũ trụ.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Vũ trụ trong vỏ hạt dẻ');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Gen: Lịch sử và tương lai của nhân loại','Siddhartha Mukherjee','Khoa học',2016,3,3,'Câu chuyện về di truyền học và ảnh hưởng của nó đến con người.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Gen: Lịch sử và tương lai của nhân loại');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'English Grammar in Use','Raymond Murphy','Ngoại ngữ',2019,5,5,'Tài liệu thực hành ngữ pháp tiếng Anh theo từng chủ đề.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='English Grammar in Use');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Dế Mèn phiêu lưu ký','Tô Hoài','Thiếu nhi',1941,6,6,'Cuộc phiêu lưu giàu bài học về tình bạn và sự trưởng thành.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Dế Mèn phiêu lưu ký');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Hoàng tử bé','Antoine de Saint-Exupéry','Thiếu nhi',1943,5,5,'Câu chuyện giàu tưởng tượng về tình yêu, tình bạn và trách nhiệm.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Hoàng tử bé');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Mắt biếc','Nguyễn Nhật Ánh','Truyện tranh',1990,4,4,'Câu chuyện tuổi học trò về tình yêu trong sáng và những kỷ niệm đẹp.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Mắt biếc');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Sức mạnh của hiện tại','Eckhart Tolle','Sức khỏe',1997,4,4,'Những thực hành giúp sống tỉnh thức và cân bằng trong hiện tại.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Sức mạnh của hiện tại');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Why We Sleep','Matthew Walker','Sức khỏe',2017,3,3,'Giải thích vai trò của giấc ngủ đối với sức khỏe và trí nhớ.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Why We Sleep');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Into the Wild','Jon Krakauer','Du lịch',1996,3,3,'Hành trình khám phá thiên nhiên và giới hạn của con người.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Into the Wild');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Nhà giả kim và hành trình tâm linh','Nguyễn Hiến Lê','Tôn giáo',2008,2,2,'Những suy ngẫm về niềm tin, mục đích sống và hành trình nội tâm.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Nhà giả kim và hành trình tâm linh');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Tâm lý học đám đông','Gustave Le Bon','Xã hội học',1895,3,3,'Phân tích hành vi và tâm lý của con người trong cộng đồng.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Tâm lý học đám đông');
INSERT INTO books(title,author,category,year,quantity,available,description)
SELECT 'Lược sử triết học','Will Durant','Triết học',1926,3,3,'Tổng quan các tư tưởng và triết gia quan trọng trong lịch sử.'
WHERE NOT EXISTS (SELECT 1 FROM books WHERE title='Lược sử triết học');