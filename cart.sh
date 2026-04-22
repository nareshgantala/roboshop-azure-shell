#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "Install nodejs"
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs &> /dev/null
step_status "nodejs installation"

copy_service_file cart

add_appuser

rm -rf /app
mkdir -p /app

print_comment "$YELLOW" "download cart code"
rm -rf /tmp/cart.zip
curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/cart.zip
step_status "download cart code"
cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/cart.zip
step_status "unzip code"

print_comment "$YELLOW" "install node dependencies"
npm install --production
step_status "install node dependencies"

print_comment "$YELLOW" "configure permissions for appuser"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "Permissions setup"

print_comment "$YELLOW" "restart cart service"
systemctl daemon-reload
systemctl enable cart
systemctl restart cart
step_status "restart cart service"
