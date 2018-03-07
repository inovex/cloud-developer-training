package de.inovex.training.whiskystore.orders.products;

import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.Path;

public interface ProductsService {

    @GET("products/{id}")
    Call<Product> product(@Path("id") Long productId);
}
