#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=orders

print_comment "$YELLOW" "java, maven installation"
dnf install -y java-21-openjdk java-21-openjdk-devel maven
step_status "java, maven installation"

copy_service_file $component_name

add_appuser

rm -rf /app

print_comment "$YELLOW" "$component_name code download"
curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip
step_status "$component_name code download"

mkdir -p /app && cd /app

print_comment "$component_name code download"
unzip /tmp/$component_name.zip
step_status "unzip $component_name code"

print_comment "build with maven"
mvn clean package -DskipTests
step_status "build with maven"

print_comment "copy jar file to /app"
cp target/$component_name.jar /app/$component_name.jar
step_status "copy jar file to /app"

print_comment "configure permission for appuser"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure permission for appuser"

system_restart