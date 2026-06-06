import java.sql.*;

public class ExportSQL {
    private static final String URL =
        "jdbc:sqlserver://localhost\\TEW_SQLEXPRES;databaseName=LoginDB;encrypt=false;trustServerCertificate=true;user=sa;password=123456";

    public static void main(String[] args) throws Exception {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        try (Connection conn = DriverManager.getConnection(URL);
             Statement stmt = conn.createStatement()) {

            // 导出表结构
            StringBuilder sql = new StringBuilder();
            sql.append("-- 数据库导出: LoginDB\n");
            sql.append("-- 导出时间: ").append(new java.util.Date()).append("\n\n");

            // 获取建表语句
            ResultSet rs = stmt.executeQuery(
                "SELECT name FROM sysobjects WHERE name='user' AND xtype='U'");
            if (!rs.next()) { System.out.println("表不存在!"); return; }

            sql.append("-- 删除已存在的表\n");
            sql.append("IF OBJECT_ID('[user]', 'U') IS NOT NULL DROP TABLE [user];\nGO\n\n");

            sql.append("-- 创建表\n");
            sql.append("CREATE TABLE [user] (\n");
            sql.append("    id       INT IDENTITY(1,1) PRIMARY KEY,\n");
            sql.append("    username NVARCHAR(50) NOT NULL UNIQUE,\n");
            sql.append("    password NVARCHAR(50) NOT NULL\n");
            sql.append(");\nGO\n\n");

            // 导出数据
            sql.append("-- 插入数据\n");
            ResultSet data = stmt.executeQuery("SELECT * FROM [user]");
            while (data.next()) {
                sql.append(String.format(
                    "INSERT INTO [user] (username, password) VALUES ('%s', '%s');\n",
                    data.getString("username"), data.getString("password")));
            }
            sql.append("GO\n");

            String outPath = "C:\\Users\\赵彬QwQ\\Desktop\\java平时作业\\export_user.sql";
            java.nio.file.Files.writeString(java.nio.file.Path.of(outPath), sql.toString());
            System.out.println("已导出: " + outPath);
            System.out.println(sql.toString());
        }
    }
}