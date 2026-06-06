package com.bookstore.servlet;

import com.bookstore.dao.BookDao;
import com.bookstore.model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/book/*")
public class BookServlet extends HttpServlet {
    private final BookDao bookDao = new BookDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        if (path == null || path.equals("/") || path.equals("/list")) {
            listBooks(req, resp);
        } else if (path.startsWith("/detail")) {
            showDetail(req, resp);
        } else if (path.startsWith("/search")) {
            search(req, resp);
        } else {
            listBooks(req, resp);
        }
    }

    private void listBooks(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String category = req.getParameter("category");
        List<Book> books;
        if (category != null && !category.isEmpty()) {
            books = bookDao.findByCategory(category);
        } else {
            books = bookDao.findAll();
        }
        req.setAttribute("books", books);
        req.setAttribute("category", category);
        req.getRequestDispatcher("/book_list.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Book book = bookDao.findById(id);
            req.setAttribute("book", book);
            req.getRequestDispatcher("/book_detail.jsp").forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/book/list");
        }
    }

    private void search(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        List<Book> books = bookDao.search(keyword != null ? keyword : "");
        req.setAttribute("books", books);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/book_list.jsp").forward(req, resp);
    }
}
