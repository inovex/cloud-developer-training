package de.inovex.training.whiskystore.orders;

public class CreditCardPayment {

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

    public void setOwner(String owner) {
        this.owner = owner;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public void setCvc(String cvc) {
        this.cvc = cvc;
    }

    public void setValidTill(ValidTill validTill) {
        this.validTill = validTill;
    }

    @Override
    public String toString() {
        return "CreditCardPayment{" +
                "owner='" + owner + '\'' +
                ", number='" + number + '\'' +
                ", cvc='" + cvc + '\'' +
                ", validTill=" + validTill +
                '}';
    }
}
