#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "java, maven installation"
dnf install -y java-21-openjdk java-21-openjdk-devel maven
step_status "java, maven installation"

copy_service_file orders

add_appuser

rm -rf /app

print_comment "$YELLOW" "orders code download"
curl -L -o /tmp/orders.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/orders.zip
step_status "orders code download"

mkdir -p /app && cd /app

print_comment "orders code download"
unzip /tmp/orders.zip
step_status "unzip orders code"

print_comment "build with maven"
mvn clean package -DskipTests
step_status "build with maven"

print_comment "copy jar file to /app"
cp target/orders.jar /app/orders.jar
step_status "copy jar file to /app"

print_comment "configure permission for appuser"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure permission for appuser"

print_comment "restart orders service"
systemctl daemon-reload
systemctl enable orders
systemctl restart orders
step_status "restart orders service"