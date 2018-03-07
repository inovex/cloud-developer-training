package de.inovex.training.whiskystore.payment;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.regex.Pattern;

@RestController
public class ValidationResource {

    @PostMapping(path = "/validation", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ValidationResponse> validateCreditCard(@RequestBody CreditCardValidationRequest request) {
        // Real world implementation would contact payment provider or validator
        if (isValidNumberFormat(request.getNumber())) {
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            return new ResponseEntity<>(HttpStatus.FORBIDDEN);
        }
    }

    private boolean isValidNumberFormat(String creditCardNumber) {
        return Pattern.matches("\\d{16}", creditCardNumber);
    }
}
