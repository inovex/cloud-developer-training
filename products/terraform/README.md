# Terraform deployment

* Projekt bauen und in S3 Bucket hochladen:

    ```sh
    export TF_VAR_prefix <your-user-name>
    ./gradlew clean uploadToS3
    ```
* Terraform initialisieren und ausführen
     
    ```sh
    cd terraform
    export TF_VAR_prefix <your-user-name>
    terraform init
    terraform workspace new $TF_VAR_prefix
    # Wenn Workspace schon existiert: terraform workspace select $TF_VAR_prefix
    terraform plan
    terraform apply
    ```
* Ausgabeparameter (Beispiel):
    
    ```sh
    db = products-db.<something>.eu-central-1.rds.amazonaws.com:5432
    elb-endpoint = mbruns-images-elb-<something>.eu-central-1.elb.amazonaws.com
    example-call = curl http://mbruns-images-elb-<something>.eu-central-1.elb.amazonaws.com/products
    images-s3-bucket = mbruns-whiskystore-images
    ```
* Service aufrufen:

    ```sh
    curl "http://<elb-endpoint>/products"
    ```
* Image Scaler einrichten (siehe `imagescaler`)
* Bildernamen abrufen (mit leerem Ergebnis):

    ```sh
    curl "http://<elb-endpoint>/products/1/images" --> leeres Ergebnis
    ```
* Bilder in S3 Bucket hochladen:

    ```sh
    cd ..
    ./gradlew copyImagesToS3
    ... kurz warten, bis die Lambda getriggert wurde ...
    ```
* Bildernamen abrufen:

    ```sh
    curl "http://<elb-endpoint>/products/1/images" --> Dateinamen
    ```
