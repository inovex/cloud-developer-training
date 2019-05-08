# Endpoint

    /validation

# Responses

Yields 204 for valid and 403 for invalid credit cards

# Sample request

    curl -v -X POST -H "Content-type: application/json" -d '{"owner":"Tobias Bayer", "number":"4111111111111111", "validTill": {"month":"10", "year":"2020"}, "cvc": 123}' http://localhost:8080/validation
    
# Build & Deploy

## Build

    ./gradlew clean check
    
    
## Build Docker image + deploy

    TF_VAR_prefix=$USER AWS_PROFILE=inovex-cdt ./gradlew buildAndDeploy