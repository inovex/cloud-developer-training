# Endpoint

    /orders

# Sample creation request

    curl -v -X POST -H "Content-type: application/json" -d '{"shippingAddress":"Tobias Bayer, Lindberghstr. 3, 80939 München", "lineItems": [{"amount":"1", "productId":"1"}], "creditCardPayment": {"owner": "Tobias Bayer", "number": "4111111111111111", "cvc": "123", "validTill": {"month": 10, "year": 2023}}}' http://localhost:8080/orders

# Sample list request

    curl -v http://localhost:8080/orders