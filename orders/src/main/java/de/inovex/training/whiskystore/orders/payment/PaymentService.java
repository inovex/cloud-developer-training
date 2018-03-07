package de.inovex.training.whiskystore.orders.payment;

import de.inovex.training.whiskystore.orders.CreditCardPayment;
import de.inovex.training.whiskystore.orders.products.Product;
import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface PaymentService {

    @POST("validation")
    Call<Product> validation(@Body CreditCardPayment creditCard);
}
