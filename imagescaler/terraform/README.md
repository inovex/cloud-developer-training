# Terraform deployment

## Voraussetzung

Vor dem Deployment muss die AWS Umgebung vorbereitet werden. Das Setup hierfür liegt in `core-infra/ecs`.

## Terraform initialisieren und ausführen

Diese Funktionalität steht auch über den Gradle Task `buildAndDeploy` zur Verfügung.
     
  ```sh
  cd terraform
  export TF_VAR_prefix <your-user-name>
  terraform init
  terraform workspace new $TF_VAR_prefix
  # Wenn Workspace schon existiert: terraform workspace select $TF_VAR_prefix
  terraform plan
  terraform apply
  ```
