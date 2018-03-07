#!/usr/bin/env bash

set -xe

apt-get -y update
apt-get -y install openjdk-8-jre awscli

APP_DIR=/opt/app

mkdir -p $APP_DIR
aws s3 --region eu-central-1 cp ${bucket}/${prefix}/${jar} $APP_DIR

java \
-jar $APP_DIR/${jar} \
--spring.datasource.driverClassName=org.postgresql.Driver \
--spring.datasource.url=jdbc:postgresql://${db_endpoint}/orders?autoReconnect=true \
--spring.datasource.username=${db_user} \
--spring.datasource.password=${db_password} \
--products.endpoint=http://${products_endpoint} \
--payment.endpoint=http://${payment_endpoint}
