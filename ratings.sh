#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=ratings
print_comment "$YELLOW" "install python,mysql client"
dnf install -y python3 python3-pip mysql8.4
step_status "install python,mysql client"

copy_service_file $component_name

print_comment "$YELLOW" "download $component_name code"
rm -rf /tmp/$component_name.zip
curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip
step_status "download $component_name code"
rm -rf /app
mkdir -p /app && cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/$component_name.zip
step_status "unzip code"

print_comment "$YELLOW" "database config"
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/schema.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/app-user.sql
step_status "database config"

add_appuser

print_comment "$YELLOW" "install dependencies"
pip3 install -r /app/requirements.txt cryptography
step_status "install dependencies"

print_comment "$YELLOW" "configure permissions"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure permissions"

system_restart