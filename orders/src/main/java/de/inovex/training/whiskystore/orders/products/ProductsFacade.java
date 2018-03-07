package de.inovex.training.whiskystore.orders.products;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.util.Optional;

@Component
public class ProductsFacade {

    private static Logger log = LoggerFactory.getLogger(ProductsFacade.class);

    private ProductsService service;

    @Value("${products.endpoint}")
    private String productsServiceEndpoint;

    @PostConstruct
    public void init() {
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(productsServiceEndpoint + "/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        service = retrofit.create(ProductsService.class);
    }

    @HystrixCommand(fallbackMethod = "getFallbackProduct")
    public Optional<Product> getProduct(Long productId) {
        try {
            return Optional.ofNullable(service.product(productId).execute().body());
        } catch (IOException e) {
            log.error("Error getting product", e);
            throw new RuntimeException(e);
        }
    }

    public Optional<Product> getFallbackProduct(Long productId) {
        return Optional.of(new Product("Fallback Product", "A fallback product", -1L));
    }
}
