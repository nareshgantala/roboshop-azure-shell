#!/bin/bash

source "$(dirname "$0")/common.sh"
component_name=payment

print_comment "$YELLOW" "install python"
dnf install -y python3 python3-pip &> /dev/null
step_status "python installation"

copy_service_file $component_name

add_appuser

rm -rf /app
mkdir -p /app
rm -rf /tmp/$component_name.zip

print_comment "$YELLOW" "download $component_name code"
curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip &> /dev/null
step_status "download $component_name code"

cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/$component_name.zip &> /dev/null
step_status "unzip code"

print_comment "$YELLOW" "install dependencies"
pip3 install -r requirements.txt &> /dev/null
step_status "install dependencies"

print_comment "$YELLOW" "configure appuser permissions"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure appuser permissions"

system_restart
