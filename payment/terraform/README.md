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

