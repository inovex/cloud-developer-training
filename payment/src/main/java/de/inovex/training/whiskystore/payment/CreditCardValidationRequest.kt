package de.inovex.training.whiskystore.payment

data class CreditCardValidationRequest (
    val owner: String,
    val number: String,
    val cvc: String,
    val validTill: ValidTill
)
