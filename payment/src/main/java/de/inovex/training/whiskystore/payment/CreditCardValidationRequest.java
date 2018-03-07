package de.inovex.training.whiskystore.payment;

public class CreditCardValidationRequest {

    private String owner;

    private String number;

    private String cvc;

    private ValidTill validTill;

    public String getOwner() {
        return owner;
    }

    public String getNumber() {
        return number;
    }

    public String getCvc() {
        return cvc;
    }

    public ValidTill getValidTill() {
        return validTill;
    }
}
