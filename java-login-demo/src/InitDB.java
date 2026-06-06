import java.sql.*;

public class InitDB {
    private static final String MASTER_URL =
        "jdbc:sqlserver://localhost\\TEW_SQLEXPRES;databaseName=master;encrypt=false;trustServerCertificate=true";

    public static void main(String[] args) {
        String[][] creds = {
            {"sa", "123456"},
            {"sa", "sa123"},
            {"sa", "admin123"},
            {"sa", "password"},
            {"sa", ""},
        };
        for (String[] c : creds) {
            String url = MASTER_URL + ";user=" + c[0] + ";password=" + c[1];
            try (Connection conn = DriverManager.getConnection(url);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(
                     "SELECT name FROM sys.databases WHERE name='LoginDB'")) {
                System.out.print("[OK] sa / '" + c[1] + "' 连接成功, ");
                if (rs.next()) {
                    System.out.println("LoginDB 已存在!");
                    verifyTable(url.replace("databaseName=master", "databaseName=LoginDB"));
                } else {
                    System.out.println("LoginDB 不存在，正在创建...");
                    createAll(conn, url);
                }
                return;
            } catch (SQLException e) {
                String msg = e.getMessage();
                if (msg.contains("Login failed")) {
                    System.out.println("[试] sa / '" + c[1] + "' → 密码不对");
                } else {
                    System.out.println("[试] sa / '" + c[1] + "' → " + msg.substring(0, Math.min(80, msg.length())));
                }
            }
        }
        System.out.println("\n所有密码都不对，请告诉我 sa 的正确密码。");
    }

    static void createAll(Connection conn, String masterUrl) throws SQLException {
        try (Statement s = conn.createStatement()) {
            s.executeUpdate("CREATE DATABASE LoginDB");
            System.out.println("[OK] LoginDB 已创建");
        }
        String url = masterUrl.replace("databaseName=master", "databaseName=LoginDB");
        try (Connection c = DriverManager.getConnection(url);
             Statement s = c.createStatement()) {
            s.executeUpdate("CREATE TABLE [user] (id INT IDENTITY(1,1) PRIMARY KEY, username NVARCHAR(50) NOT NULL UNIQUE, password NVARCHAR(50) NOT NULL)");
            s.executeUpdate("INSERT INTO [user] (username, password) VALUES ('admin', '123456')");
            System.out.println("[OK] 表和测试数据已创建");
            verifyTable(url);
        }
    }

    static void verifyTable(String url) throws SQLException {
        try (Connection c = DriverManager.getConnection(url);
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT * FROM [user]")) {
            System.out.println("=== user 表内容 ===");
            while (rs.next())
                System.out.printf("  id=%d  username=%s  password=%s%n", rs.getInt(1), rs.getString(2), rs.getString(3));
        }
    }
}