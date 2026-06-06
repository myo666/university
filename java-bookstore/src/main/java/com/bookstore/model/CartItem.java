package com.bookstore.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class CartItem implements Serializable {
    private int bookId;
    private String title;
    private BigDecimal price;
    private int quantity;

    public CartItem() {}

    public CartItem(int bookId, String title, BigDecimal price, int quantity) {
        this.bookId = bookId; this.title = title;
        this.price = price; this.quantity = quantity;
    }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }

    public BigDecimal getSubtotal() {
        return price.multiply(new BigDecimal(quantity));
    }
}
