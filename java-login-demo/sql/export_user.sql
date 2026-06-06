-- 数据库导出: LoginDB
-- 导出时间: Sat Jun 06 12:52:52 CST 2026

-- 删除已存在的表
IF OBJECT_ID('[user]', 'U') IS NOT NULL DROP TABLE [user];
GO

-- 创建表
CREATE TABLE [user] (
    id       INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    password NVARCHAR(50) NOT NULL
);
GO

-- 插入数据
INSERT INTO [user] (username, password) VALUES ('admin', '123456');
GO
