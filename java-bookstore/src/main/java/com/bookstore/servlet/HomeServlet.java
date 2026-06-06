package com.bookstore.servlet;

import com.bookstore.dao.BookDao;
import com.bookstore.model.Book;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/index")
public class HomeServlet extends HttpServlet {
    private final BookDao bookDao = new BookDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        List<Book> books = bookDao.findAll();
        req.setAttribute("books", books);
        req.getRequestDispatcher("/index.jsp").forward(req, resp);
    }
}