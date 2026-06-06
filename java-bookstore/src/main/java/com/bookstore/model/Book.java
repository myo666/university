package com.bookstore.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class Book implements Serializable {
    private int id;
    private String title;
    private String author;
    private String publisher;
    private BigDecimal price;
    private int stock;
    private String cover;
    private String description;
    private String category;

    public Book() {}

    public Book(int id, String title, String author, String publisher,
                BigDecimal price, int stock, String cover, String description, String category) {
        this.id = id; this.title = title; this.author = author;
        this.publisher = publisher; this.price = price; this.stock = stock;
        this.cover = cover; this.description = description; this.category = category;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getAuthor() { return author; }
    public void setAuthor(String author) { this.author = author; }
    public String getPublisher() { return publisher; }
    public void setPublisher(String publisher) { this.publisher = publisher; }
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
    public String getCover() { return cover; }
    public void setCover(String cover) { this.cover = cover; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}
