package com.bookstore.servlet;

import com.bookstore.dao.UserDao;
import com.bookstore.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/user/*")
public class UserServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();
        if ("/logout".equals(path)) {
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/");
        } else if ("/login".equals(path)) {
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else if ("/register".equals(path)) {
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();

        if ("/login".equals(path)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            User user = userDao.login(username, password);
            if (user != null) {
                req.getSession().setAttribute("user", user);
                resp.sendRedirect(req.getContextPath() + "/");
            } else {
                req.setAttribute("error", "用户名或密码错误");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            }
        } else if ("/register".equals(path)) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            if (userDao.findByUsername(username) != null) {
                req.setAttribute("error", "用户名已存在");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
                return;
            }
            User user = new User(0, username, password, email, phone);
            if (userDao.register(user)) {
                req.setAttribute("msg", "注册成功，请登录");
                req.getRequestDispatcher("/login.jsp").forward(req, resp);
            } else {
                req.setAttribute("error", "注册失败");
                req.getRequestDispatcher("/register.jsp").forward(req, resp);
            }
        }
    }
}
