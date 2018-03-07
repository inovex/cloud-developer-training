package de.inovex.training.whiskystore.orders;

import com.fasterxml.jackson.annotation.JsonInclude;

import javax.persistence.*;
import java.util.Collection;

@Entity
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "order", targetEntity=LineItem.class, fetch=FetchType.EAGER, cascade = {CascadeType.PERSIST})
    private Collection<LineItem> lineItems;

    private String shippingAddress;

    @Transient
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private CreditCardPayment creditCardPayment;

    @PrePersist
    public void setLineItemsParent() {
        lineItems.forEach(lineItem -> lineItem.setOrder(this));
    }

    public Collection<LineItem> getLineItems() {
        return lineItems;
    }

    public void setLineItems(Collection<LineItem> lineItems) {
        this.lineItems = lineItems;
    }

    public String getShippingAddress() {
        return shippingAddress;
    }

    public void setShippingAddress(String shippingAddress) {
        this.shippingAddress = shippingAddress;
    }

    public CreditCardPayment getCreditCardPayment() {
        return creditCardPayment;
    }

    public void setCreditCardPayment(CreditCardPayment creditCardPayment) {
        this.creditCardPayment = creditCardPayment;
    }

    @Override
    public String toString() {
        return "Order{" +
                "id=" + id +
                ", lineItems=" + lineItems +
                ", shippingAddress='" + shippingAddress + '\'' +
                ", creditCardPayment=" + creditCardPayment +
                '}';
    }
}
