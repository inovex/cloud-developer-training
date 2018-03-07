# Terraform deployment

* Credentials speichern
  * https://console.aws.amazon.com/iam/home?region=eu-central-1#/users
  * User auswählen, Reiter Security credentials
  * Create access key
  * Datei `~/.aws/credentials` anlegen:

        ```shell
        [javaland]
        aws_access_key_id=<your-access-key-id>
        aws_secret_access_key=<your-secret-access-key>
        ```
  * Alternative Env-Variablen:

        ```shell
        export AWS_ACCESS_KEY_ID=<your-access-key-id>
        export AWS_SECRET_ACCESS_KEY=<your-secret-access-key>
        ```
* Projekt bauen und in S3 Bucket hochladen:

      ```shell
      export TF_VAR_prefix <your-user-name>
      ./gradlew clean uploadToS3
      ```
* Terraform initialisieren und ausführen
     
      ```shell
      cd terraform
      export TF_VAR_prefix <your-user-name>
      terraform init
      terraform workspace new $TF_VAR_prefix
      # Wenn Workspace schon existiert: terraform workspace select $TF_VAR_prefix
      terraform plan
      terraform apply
      ```
* Ausgabeparameter (Beispiel):
    
    ```
    db = products-db.<something>.eu-central-1.rds.amazonaws.com:5432
    elb-endpoint = mbruns-images-elb-<something>.eu-central-1.elb.amazonaws.com
    example-call = curl http://mbruns-images-elb-<something>.eu-central-1.elb.amazonaws.com/products
    images-s3-bucket = mbruns-whiskystore-images
    ```
* Service aufrufen:

      ```shell
      curl "http://<elb-endpoint>/products"
      ```
* Image Scaler einrichten (siehe `imagescaler`)
* Bildernamen abrufen (mit leerem Ergebnis):

      ```shell
      curl "http://<elb-endpoint>/products/1/images" --> leeres Ergebnis
      ```
* Bilder in S3 Bucket hochladen:

      ```shell
      cd ..
      ./gradlew copyImagesToS3
      ... kurz warten, bis die Lambda getriggert wurde ...
      ```
* Bildernamen abrufen:

      ```shell
      curl "http://<elb-endpoint>/products/1/images" --> Dateinamen
      ```
