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
