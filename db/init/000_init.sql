-- 在此目录放置你的建表和初始化数据 SQL 文件。
-- Docker Compose 会将该目录挂载到 /docker-entrypoint-initdb.d
-- 容器首次启动时会自动执行这些 .sql / .sql.gz / .sh 文件（按文件名排序）

-- 确保数据库使用统一的字符集与排序规则（MySQL 8 推荐）
CREATE DATABASE IF NOT EXISTS my_database CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE my_database;

SET FOREIGN_KEY_CHECKS = 0;
-- 删除已有表和触发器（如果存在）
DROP TRIGGER IF EXISTS before_insert_web_data_table;
DROP TABLE IF EXISTS web_data_table;
DROP TABLE IF EXISTS `user`;
DROP TABLE IF EXISTS article_rating;
DROP TABLE IF EXISTS audit_log;
-- 创建主表 web_data_table
CREATE TABLE web_data_table (
    id int NOT NULL AUTO_INCREMENT,
    formatted_id varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
    title text NOT NULL COMMENT '标题',
    author varchar(100) DEFAULT NULL COMMENT '作者',
    info_type varchar(50) DEFAULT 'T0' COMMENT '信息类型',
    post_agency varchar(80) DEFAULT NULL COMMENT '发布机构',
    nation varchar(50) DEFAULT NULL COMMENT '国家',
    article_date DATE COMMENT '日期',
    link_url VARCHAR(500) UNIQUE COMMENT '链接URL',  -- 更改为 VARCHAR(500) 以支持唯一索引
    domain varchar(50) DEFAULT 'F0' COMMENT '领域',
    subject varchar(50) DEFAULT 'AG0' COMMENT '学科',
    text text DEFAULT NULL COMMENT '正文',
    average_rating DOUBLE DEFAULT NULL COMMENT '平均评分',
    rating_count INT DEFAULT NULL COMMENT '评分次数',
    PRIMARY KEY (id),
    UNIQUE KEY formatted_id (formatted_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 创建触发器 before_insert_web_data_table
DELIMITER $$

CREATE TRIGGER before_insert_web_data_table
BEFORE INSERT ON web_data_table
FOR EACH ROW
BEGIN
    -- 检查article_date字段是否为空
    IF NEW.article_date IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Article date field cannot be NULL';
    END IF;

    -- 从article_date字段提取年月，并格式化为YYYYMM
    SET @year_month = DATE_FORMAT(NEW.article_date, '%Y%m');

    -- 初始化变量，用于存储当前年月的最大序列号
    SET @max_serial = 0;

    -- 查询当前年月已存在的formatted_id的最大序列号
  SELECT COALESCE(MAX(CAST(SUBSTRING(formatted_id, 8) AS UNSIGNED)), 0) INTO @max_serial
  FROM web_data_table
  WHERE formatted_id LIKE (CONCAT(@year_month, '%') COLLATE utf8mb4_0900_ai_ci);

    -- 计算新记录的序列号
    SET @new_serial = @max_serial + 1;

    -- 构造新的formatted_id
    SET NEW.formatted_id = CONCAT(@year_month, '-', LPAD(@new_serial, 4, '0'));
END$$

DELIMITER ;
-- 创建用户表 user
CREATE TABLE `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `role` enum('EXPERT','LIBRARIAN','ADMIN') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
-- 创建评分表 article_rating
CREATE TABLE `article_rating` (
  `id` int NOT NULL AUTO_INCREMENT,
  `article_id` int NOT NULL,  -- 修改为 int 类型，引用 web_data_table 的主键 id
  `expert_id` int NOT NULL,
 `innovation_score` INT NOT NULL CHECK (innovation_score BETWEEN 0 AND 10),
  `disruption_score` INT NOT NULL CHECK (disruption_score BETWEEN 0 AND 10),
  `frontier_score` INT NOT NULL CHECK (frontier_score BETWEEN 0 AND 10),
  `industry_impact_score` INT NOT NULL CHECK (industry_impact_score BETWEEN 0 AND 10),
  `additional_score` INT NOT NULL DEFAULT 0 CHECK (additional_score BETWEEN 0 AND 10),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_article_expert` (`article_id`,`expert_id`),
  KEY `article_rating_ibfk_1_idx` (`article_id`),
  KEY `article_rating_ibfk_2_idx` (`expert_id`),
  CONSTRAINT `fk_article_id` FOREIGN KEY (`article_id`) 
    REFERENCES `web_data_table` (`id`)  -- 引用 web_data_table 的主键 id
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_expert_id` FOREIGN KEY (`expert_id`) 
    REFERENCES `user` (`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 创建审核日志表 audit_log
CREATE TABLE audit_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    operation VARCHAR(100) NOT NULL,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    INDEX idx_audit_log_username (username),
    INDEX idx_audit_log_operation (operation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SET FOREIGN_KEY_CHECKS = 1;