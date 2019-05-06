package de.inovex.training.whiskystore.payment

import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

import java.util.regex.Pattern

@RestController
class ValidationResource {

    @PostMapping(path = ["/validation"], produces = [MediaType.APPLICATION_JSON_VALUE])
    fun validateCreditCard(@RequestBody request: CreditCardValidationRequest): ResponseEntity<ValidationResponse> =
        // Real-world implementation would contact payment provider or validator
        when (isValidNumberFormat(request.number)) {
            true -> ResponseEntity(HttpStatus.NO_CONTENT)
            else -> ResponseEntity(HttpStatus.FORBIDDEN)
        }

    private fun isValidNumberFormat(creditCardNumber: String): Boolean =
        Pattern.matches("\\d{16}", creditCardNumber)

}
