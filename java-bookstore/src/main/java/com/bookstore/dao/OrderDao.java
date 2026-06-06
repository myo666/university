package com.bookstore.dao;

import com.bookstore.model.CartItem;
import com.bookstore.model.Order;
import com.bookstore.util.DBUtil;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class OrderDao {

    public int createOrder(int userId, List<CartItem> items) {
        String orderSql = "INSERT INTO orders (user_id, total_amount, status) OUTPUT INSERTED.id VALUES (?, ?, 'paid')";
        String itemSql = "INSERT INTO order_items (order_id, book_id, quantity, price) VALUES (?, ?, ?, ?)";
        String stockSql = "UPDATE books SET stock = stock - ? WHERE id = ?";

        BigDecimal total = items.stream()
            .map(CartItem::getSubtotal)
            .reduce(BigDecimal.ZERO, BigDecimal::add);

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                try (PreparedStatement ps = conn.prepareStatement(orderSql)) {
                    ps.setInt(1, userId);
                    ps.setBigDecimal(2, total);
                    try (ResultSet rs = ps.executeQuery()) {
                        rs.next();
                        orderId = rs.getInt(1);
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(itemSql)) {
                    for (CartItem item : items) {
                        ps.setInt(1, orderId); ps.setInt(2, item.getBookId());
                        ps.setInt(3, item.getQuantity()); ps.setBigDecimal(4, item.getPrice());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                try (PreparedStatement ps = conn.prepareStatement(stockSql)) {
                    for (CartItem item : items) {
                        ps.setInt(1, item.getQuantity()); ps.setInt(2, item.getBookId());
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }
                conn.commit();
                return orderId;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) { e.printStackTrace(); return -1; }
    }

    public List<Order> findByUserId(int userId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Order(
                        rs.getInt("id"), rs.getInt("user_id"),
                        rs.getBigDecimal("total_amount"),
                        rs.getString("status"), rs.getTimestamp("created_at")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    /** 取消订单：仅"paid"状态可取消，恢复库存，事务操作 */
    public boolean cancelOrder(int orderId, int userId) {
        String checkSql = "SELECT status FROM orders WHERE id = ? AND user_id = ?";
        String updateSql = "UPDATE orders SET status = 'cancelled' WHERE id = ?";
        String stockSql = "UPDATE books SET stock = stock + oi.quantity " +
                          "FROM order_items oi WHERE books.id = oi.book_id AND oi.order_id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, orderId); ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !"paid".equals(rs.getString("status"))) {
                            conn.rollback(); return false;
                        }
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, orderId); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(stockSql)) {
                    ps.setInt(1, orderId); ps.executeUpdate();
                }
                conn.commit(); return true;
            } catch (SQLException e) { conn.rollback(); throw e; }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    /** 删除订单：仅"cancelled"状态可删除，先删明细再删主记录，事务操作 */
    public boolean deleteOrder(int orderId, int userId) {
        String checkSql = "SELECT status FROM orders WHERE id = ? AND user_id = ?";
        String deleteItemsSql = "DELETE FROM order_items WHERE order_id = ?";
        String deleteOrderSql = "DELETE FROM orders WHERE id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                    ps.setInt(1, orderId); ps.setInt(2, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next() || !"cancelled".equals(rs.getString("status"))) {
                            conn.rollback(); return false;
                        }
                    }
                }
                try (PreparedStatement ps = conn.prepareStatement(deleteItemsSql)) {
                    ps.setInt(1, orderId); ps.executeUpdate();
                }
                try (PreparedStatement ps = conn.prepareStatement(deleteOrderSql)) {
                    ps.setInt(1, orderId); ps.executeUpdate();
                }
                conn.commit(); return true;
            } catch (SQLException e) { conn.rollback(); throw e; }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<CartItem> findOrderItems(int orderId) {
        List<CartItem> items = new ArrayList<>();
        String sql = "SELECT oi.*, b.title, b.author FROM order_items oi JOIN books b ON oi.book_id = b.id WHERE oi.order_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    items.add(new CartItem(
                            rs.getInt("book_id"),
                            rs.getString("title"),
                            rs.getBigDecimal("price"),
                            rs.getInt("quantity")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return items;
    }
}