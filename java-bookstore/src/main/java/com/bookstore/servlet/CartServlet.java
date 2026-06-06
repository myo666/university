package com.bookstore.servlet;

import com.bookstore.dao.BookDao;
import com.bookstore.model.Book;
import com.bookstore.model.CartItem;
import com.bookstore.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@WebServlet("/cart/*")
public class CartServlet extends HttpServlet {
    private final BookDao bookDao = new BookDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();

        if ("/count".equals(path)) {
            cartCount(req, resp);
            return;
        }
        if ("/remove".equals(path)) {
            removeItem(req, resp);
        } else {
            req.getRequestDispatcher("/cart.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo();

        if ("/add".equals(path)) {
            addToCart(req, resp);
        } else if ("/update".equals(path)) {
            updateCart(req, resp);
        }
    }

    @SuppressWarnings("unchecked")
    private void addToCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.getWriter().write("{\"success\":false,\"msg\":\"请先登录\"}");
            return;
        }
        int bookId = Integer.parseInt(req.getParameter("bookId"));
        int buyQty = 1;
        try { buyQty = Integer.parseInt(req.getParameter("quantity")); } catch (Exception ignored) {}
        Book book = bookDao.findById(bookId);
        if (book == null || book.getStock() <= 0) {
            resp.getWriter().write("{\"success\":false,\"msg\":\"商品不存在或已售罄\"}");
            return;
        }
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null) { cart = new LinkedHashMap<>(); session.setAttribute("cart", cart); }
        CartItem existing = cart.get(bookId);
        int newQty = (existing != null ? existing.getQuantity() : 0) + buyQty;
        if (newQty > book.getStock()) {
            resp.getWriter().write("{\"success\":false,\"msg\":\"库存不足，当前库存 " + book.getStock() + "，购物车已有 " + (existing != null ? existing.getQuantity() : 0) + "\"}");
            return;
        }
        cart.put(bookId, new CartItem(bookId, book.getTitle(), book.getPrice(), newQty));
        resp.getWriter().write("{\"success\":true,\"count\":" + cart.size() + "}");
    }

    @SuppressWarnings("unchecked")
    private void updateCart(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int bookId = Integer.parseInt(req.getParameter("bookId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart != null) {
            if (quantity <= 0) {
                cart.remove(bookId);
            } else {
                CartItem item = cart.get(bookId);
                if (item != null) item.setQuantity(quantity);
            }
        }
        resp.sendRedirect(req.getContextPath() + "/cart/");
    }

    @SuppressWarnings("unchecked")
    private void cartCount(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        int count = cart != null ? cart.size() : 0;
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"count\":" + count + "}");
    }

    @SuppressWarnings("unchecked")
    private void removeItem(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        int bookId = Integer.parseInt(req.getParameter("bookId"));
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart != null) cart.remove(bookId);
        resp.sendRedirect(req.getContextPath() + "/cart/");
    }
}
