-- =====================================================
-- 知阅书城 数据库初始化脚本
-- 数据库: SQL Server
-- 实例: localhost\TEW_SQLEXPRES
-- =====================================================

-- 创建数据库（如果不存在）
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'BookStoreDB')
BEGIN
    CREATE DATABASE BookStoreDB;
END
GO

USE BookStoreDB;
GO

-- 用户表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
CREATE TABLE users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(100) NOT NULL,
    email NVARCHAR(100),
    phone NVARCHAR(20)
);

-- 图书表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'books')
CREATE TABLE books (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    author NVARCHAR(100) NOT NULL,
    publisher NVARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    cover NVARCHAR(200),
    description NVARCHAR(MAX),
    category NVARCHAR(50)
);

-- 订单表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'orders')
CREATE TABLE orders (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id),
    total_amount DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'paid',
    created_at DATETIME DEFAULT GETDATE()
);

-- 订单明细表
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'order_items')
CREATE TABLE order_items (
    id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(id),
    book_id INT NOT NULL REFERENCES books(id),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL
);
GO

-- ==================== 测试数据 ====================

INSERT INTO users (username, password, email, phone) VALUES
('test', '123456', 'test@example.com', '13800138000');

INSERT INTO books (title, author, publisher, price, stock, description, category) VALUES
(N'活着', N'余华', N'作家出版社', 29.90, 50, N'《活着》是余华的代表作之一，讲述了一个人一生的故事，展现了中国社会几十年的变迁。', N'文学'),
(N'三体', N'刘慈欣', N'重庆出版社', 68.00, 30, N'《三体》是刘慈欣创作的系列长篇科幻小说，讲述了地球人类文明和三体文明的信息交流、生死搏杀及两个文明在宇宙中的兴衰历程。', N'科技'),
(N'人类简史', N'尤瓦尔·赫拉利', N'中信出版社', 49.00, 40, N'从十万年前有生命迹象开始到21世纪资本、科技交织的人类发展史，将人类历史从石器时代到21世纪的演化做了全面的梳理。', N'历史'),
(N'论语', N'孔子', N'中华书局', 18.00, 60, N'《论语》是儒家学派的经典著作之一，记录了孔子及其弟子的言行，集中体现了孔子的政治主张、伦理思想、道德观念及教育原则等。', N'哲学'),
(N'经济学原理', N'曼昆', N'北京大学出版社', 75.00, 25, N'曼昆的《经济学原理》是世界上最流行的经济学入门教材，用通俗易懂的语言解释了经济学的核心概念。', N'经济'),
(N'百年孤独', N'加西亚·马尔克斯', N'南海出版公司', 39.50, 35, N'《百年孤独》是魔幻现实主义文学的代表作，描写了布恩迪亚家族七代人的传奇故事。', N'文学'),
(N'围城', N'钱锺书', N'人民文学出版社', 25.00, 45, N'《围城》是中国现代文学史上一部风格独特的讽刺小说，被誉为"新儒林外史"。', N'文学'),
(N'时间简史', N'史蒂芬·霍金', N'湖南科学技术出版社', 45.00, 20, N'《时间简史》是英国物理学家霍金创作的科学著作，讲述了宇宙的起源、结构和命运。', N'科技'),
(N'红楼梦', N'曹雪芹', N'人民文学出版社', 55.00, 40, N'中国古典四大名著之首，以贾、史、王、薛四大家族的兴衰为背景，展现了封建社会的人生百态。', N'文学'),
(N'思考，快与慢', N'丹尼尔·卡尼曼', N'中信出版社', 69.00, 15, N'诺贝尔经济学奖得主丹尼尔·卡尼曼的经典作品，探讨了人类认知的两个系统如何影响决策。', N'哲学'),
(N'万历十五年', N'黄仁宇', N'中华书局', 32.00, 30, N'以1587年为切入点，通过对关键人物命运的描述，探析了明朝乃至整个中国古代社会的结构性问题。', N'历史'),
(N'原则', N'瑞·达利欧', N'中信出版社', 89.00, 18, N'桥水基金创始人瑞·达利欧的人生经验之作，分享了生活和工作中的原则。', N'经济');