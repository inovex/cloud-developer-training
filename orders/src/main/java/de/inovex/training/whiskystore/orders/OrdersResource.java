package de.inovex.training.whiskystore.orders;

import de.inovex.training.whiskystore.orders.payment.PaymentFacade;
import de.inovex.training.whiskystore.orders.products.ProductsFacade;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
public class OrdersResource {

    private static Logger log = LoggerFactory.getLogger(OrdersResource.class);

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private ProductsFacade productsFacade;

    @Autowired
    private PaymentFacade paymentFacade;

    @PostMapping(path = "/orders")
    public ResponseEntity<CreateOrderResponse> createOrder(@RequestBody Order order) {
        log.info("Incoming order: {}", order);

        if (paymentFacade.validate(order.getCreditCardPayment())) {
            addPrices(order);

            orderRepository.save(order);

            return ResponseEntity.ok(null);
        } else {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
    }

    @GetMapping(path = "/orders")
    public ResponseEntity<List<Order>> getOrders() {
        return ResponseEntity.ok(orderRepository.findAll());
    }

    @GetMapping(path = "/orders/{orderId}")
    public ResponseEntity<Order> getOrder(@PathVariable Long orderId) {
        Optional<Order> order = orderRepository.findById(orderId);
        return order
                .map(ResponseEntity::ok)
                .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
    }

    private void addPrices(Order order) {
        order.getLineItems().stream()
                .forEach(lineItem -> productsFacade.getProduct(lineItem.getProductId()).ifPresent(
                        product -> lineItem.setPricePerUnit(product.getPrice())));
    }
}
