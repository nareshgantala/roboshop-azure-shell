#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "install nodejs"
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
step_status "install nodejs"

if [ -f user.service ]
then
    print_comment "copying user service file"
    cp user.service /etc/systemd/system/user.service
    step_status "copy user service file"
else
    print_comment "$RED" "user service file doesnot exist"
    exit 1
fi
rm -rf /app
mkdir -p /app
print_comment "$YELLOW" "download user code"
curl -L -o /tmp/user.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/user.zip
step_status "download user code"

cd /app
print_comment "$YELLOW" "unzip code"
unzip /tmp/user.zip
step_status "unzip code"

print_comment "$YELLOW" "install node dependencies"
npm install --production
step_status "install node dependencies"

print_comment "$YELLOW" "configure permisison"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure permisison"

print_comment "$YELLOW" "restart user service"
systemctl daemon-reload
systemctl enable user
systemctl start user
step_status "restart user service"