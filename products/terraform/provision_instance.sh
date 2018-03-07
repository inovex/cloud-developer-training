#!/usr/bin/env bash

set -xe

apt-get -y update
apt-get -y install openjdk-8-jre awscli

APP_DIR=/opt/app

mkdir -p $APP_DIR
aws s3 --region eu-central-1 cp ${bucket}/${prefix}/${jar} $APP_DIR

AWS_S3_BUCKET=${images_bucket} \
  AWS_S3_REGION=${images_bucket_region} \
  AWS_S3_PREFIX=${images_bucket_prefix} \
  java \
  -jar $APP_DIR/${jar} \
  --spring.datasource.driverClassName=org.postgresql.Driver \
  --spring.datasource.url=jdbc:postgresql://${db_endpoint}/products?autoReconnect=true \
  --spring.datasource.username=${db_user} \
  --spring.datasource.password=${db_password}
