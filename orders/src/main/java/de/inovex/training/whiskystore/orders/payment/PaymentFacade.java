package de.inovex.training.whiskystore.orders.payment;

import com.netflix.hystrix.contrib.javanica.annotation.HystrixCommand;
import de.inovex.training.whiskystore.orders.CreditCardPayment;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import javax.annotation.PostConstruct;
import java.io.IOException;

@Component
public class PaymentFacade {

    private static Logger log = LoggerFactory.getLogger(PaymentFacade.class);

    private PaymentService service;

    @Value("${payment.endpoint}")
    private String paymentServiceEndpoint;

    @PostConstruct
    public void init() {
        Retrofit retrofit = new Retrofit.Builder()
                .baseUrl(paymentServiceEndpoint + "/")
                .addConverterFactory(GsonConverterFactory.create())
                .build();

        service = retrofit.create(PaymentService.class);
    }

    @HystrixCommand(fallbackMethod = "fallbackValidate")
    public boolean validate(CreditCardPayment creditCard) {
        try {
            return service.validation(creditCard).execute().isSuccessful();
        } catch (IOException e) {
            log.error("Error validating credit card", e);
            throw new RuntimeException(e);
        }
    }

    public boolean fallbackValidate(CreditCardPayment creditCard) {
        return false;
    }
}
