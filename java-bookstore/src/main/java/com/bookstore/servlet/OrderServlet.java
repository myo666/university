package com.bookstore.servlet;

import com.bookstore.dao.OrderDao;
import com.bookstore.model.CartItem;
import com.bookstore.model.Order;
import com.bookstore.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/order/*")
public class OrderServlet extends HttpServlet {
    private final OrderDao orderDao = new OrderDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/user/login");
            return;
        }
        String path = req.getPathInfo();
        if ("/detail".equals(path)) {
            int orderId = Integer.parseInt(req.getParameter("id"));
            List<CartItem> items = orderDao.findOrderItems(orderId);
            req.setAttribute("orderItems", items);
            req.getRequestDispatcher("/order_detail.jsp").forward(req, resp);
            return;
        }
        List<Order> orders = orderDao.findByUserId(user.getId());
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/order_list.jsp").forward(req, resp);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = (User) req.getSession().getAttribute("user");
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/user/login");
            return;
        }
        String path = req.getPathInfo();

        // 取消订单
        if ("/cancel".equals(path)) {
            int orderId = Integer.parseInt(req.getParameter("id"));
            boolean ok = orderDao.cancelOrder(orderId, user.getId());
            if (ok) {
                req.setAttribute("msg", "订单 #" + orderId + " 已取消");
            } else {
                req.setAttribute("error", "取消失败，订单不存在或状态不允许取消");
            }
            List<Order> orders = orderDao.findByUserId(user.getId());
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/order_list.jsp").forward(req, resp);
            return;
        }

        // 删除订单
        if ("/delete".equals(path)) {
            int orderId = Integer.parseInt(req.getParameter("id"));
            boolean ok = orderDao.deleteOrder(orderId, user.getId());
            if (ok) {
                req.setAttribute("msg", "订单 #" + orderId + " 已删除");
            } else {
                req.setAttribute("error", "删除失败，订单不存在或状态不允许删除");
            }
            List<Order> orders = orderDao.findByUserId(user.getId());
            req.setAttribute("orders", orders);
            req.getRequestDispatcher("/order_list.jsp").forward(req, resp);
            return;
        }

        // 提交订单
        HttpSession session = req.getSession();
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");
        if (cart == null || cart.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/cart/");
            return;
        }
        List<CartItem> items = new ArrayList<>(cart.values());
        int orderId = orderDao.createOrder(user.getId(), items);
        if (orderId > 0) {
            session.removeAttribute("cart");
            req.setAttribute("msg", "下单成功！订单号：" + orderId);
        } else {
            req.setAttribute("error", "下单失败，请重试");
        }
        List<Order> orders = orderDao.findByUserId(user.getId());
        req.setAttribute("orders", orders);
        req.getRequestDispatcher("/order_list.jsp").forward(req, resp);
    }
}