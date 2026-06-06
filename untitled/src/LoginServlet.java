import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final String URL  = "jdbc:sqlserver://localhost\\TEW_SQLEXPRES;databaseName=LoginDB;encrypt=false";
    private static final String USER = "sa";
    private static final String PASS = "123456";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || password == null || username.isBlank() || password.isBlank()) {
            req.setAttribute("msg", "用户名或密码不能为空");
            req.getRequestDispatcher("fail.jsp").forward(req, resp);
            return;
        }

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            try (Connection conn = DriverManager.getConnection(URL, USER, PASS);
                 PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM [user] WHERE username = ? AND password = ?")) {

                ps.setString(1, username);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.setAttribute("username", username);
                        req.getRequestDispatcher("success.jsp").forward(req, resp);
                    } else {
                        req.setAttribute("msg", "用户名或密码错误");
                        req.getRequestDispatcher("fail.jsp").forward(req, resp);
                    }
                }
            }
        } catch (ClassNotFoundException e) {
            req.setAttribute("msg", "系统错误：数据库驱动缺失");
            req.getRequestDispatcher("fail.jsp").forward(req, resp);
        } catch (SQLException e) {
            req.setAttribute("msg", "系统错误：" + e.getMessage());
            req.getRequestDispatcher("fail.jsp").forward(req, resp);
        }
    }
}