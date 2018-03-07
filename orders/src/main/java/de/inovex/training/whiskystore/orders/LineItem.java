package de.inovex.training.whiskystore.orders;

import com.fasterxml.jackson.annotation.JsonIgnore;

import javax.persistence.*;

@Entity
@Table(name = "line_items")
public class LineItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long productId;
    private Long amount;
    private Long pricePerUnit;

    @ManyToOne(optional=false)
    @JoinColumn(name="order_id", referencedColumnName="id")
    @JsonIgnore
    private Order order;

    public Long getProductId() {
        return productId;
    }

    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public Long getAmount() {
        return amount;
    }

    public void setAmount(Long amount) {
        this.amount = amount;
    }

    public Long getPricePerUnit() {
        return pricePerUnit;
    }

    public void setPricePerUnit(Long pricePerUnit) {
        this.pricePerUnit = pricePerUnit;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }

    @Override
    public String toString() {
        return "LineItem{" +
                "id=" + id +
                ", productId=" + productId +
                ", amount=" + amount +
                ", pricePerUnit=" + pricePerUnit +
                ", order=" + order +
                '}';
    }
}
