-- 禁用外键检查
SET FOREIGN_KEY_CHECKS = 0;

-- 清空表数据
TRUNCATE TABLE `user`;
TRUNCATE TABLE `web_data_table`;
TRUNCATE TABLE `article_rating`;
TRUNCATE TABLE `audit_log`;

-- 插入用户表 user 的测试数据
INSERT INTO `user` (`username`, `password`, `role`) VALUES
('expert1', 'password123', 'EXPERT'),
('librarian1', 'password123', 'LIBRARIAN'),
('admin1', 'password123', 'ADMIN');

-- 插入 web_data_table 的测试数据
INSERT INTO `web_data_table` (`title`, `author`, `info_type`, `post_agency`, `nation`, `article_date`, `link_url`, `domain`, `subject`, `text`) VALUES
('Title1', 'Author1', 'Type1', 'Agency1', 'Nation1', '2023-01-01', 'http://example.com/1', 'F1', 'Subject1', 'Text content 1'),
('Title2', 'Author2', 'Type2', 'Agency2', 'Nation2', '2023-02-01', 'http://example.com/2', 'F2', 'Subject2', 'Text content 2'),
('Title3', 'Author3', 'Type3', 'Agency3', 'Nation3', '2023-03-01', 'http://example.com/3', 'F3', 'Subject3', 'Text content 3');

-- 插入 article_rating 的测试数据，引用 web_data_table 的 id
INSERT INTO `article_rating` (`article_id`, `expert_id`, `innovation_score`, `disruption_score`, `frontier_score`, `industry_impact_score`, `additional_score`) VALUES
(1, 1, 8, 7, 9, 6, 5),
(2, 1, 7, 8, 6, 9, 4),
(3, 1, 6, 7, 8, 5, 6);

-- 插入审核日志表 audit_log 的测试数据
INSERT INTO audit_log (username, operation, details) VALUES
('expert1', 'INSERT INTO web_data_table', 'Inserted a new article with title Title1'),
('librarian1', 'UPDATE web_data_table', 'Updated title of article with id 1 to New Title'),
('admin1', 'DELETE FROM web_data_table', 'Deleted article with id 3');

-- 恢复外键检查
SET FOREIGN_KEY_CHECKS = 1;
