package de.inovex.training.whiskystore.orders.products;

public class Product {

    private Long id;
    private String name;
    private String description;
    private Long price;

    public Product() {}

    public Product(String name, String description, Long price) {
        this.name = name;
        this.description = description;
        this.price = price;
    }

    public Long getPrice() {
        return price;
    }

    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                '}';
    }
}
