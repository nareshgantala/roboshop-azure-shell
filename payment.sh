#!/bin/bash

source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "install python"
dnf install -y python3 python3-pip &> /dev/null
step_status "python installation"

if [ -f payment.service ]
then
    cp payment.service /etc/systemd/system/payment.service 
    step_status "payment service file copy"
else
    print_comment "$RED" "payment service file doesnot exist"
    exit 1
fi

id appuser &> /dev/null
if [ $? -eq 0 ]
then
    print_comment "$GREEN" "appuser alredy exists"
else
    useradd -r -s /bin/false appuser
    step_status "appuser creation"
fi

rm -rf /app
mkdir -p /app
rm -rf /tmp/payment.zip

print_comment "$YELLOW" "download payment code"
curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/payment.zip &> /dev/null
step_status "download payment code"

cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/payment.zip &> /dev/null
step_status "unzip code"

print_comment "$YELLOW" "install dependencies"
pip3 install -r requirements.txt &> /dev/null
step_status "install dependencies"

print_comment "$YELLOW" "configure appuser permissions"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure appuser permissions"

print_comment "$YELLOW" "payment service restart"
systemctl daemon-reload 
systemctl enable payment &> /dev/null
systemctl start payment 
step_status "payment service restart"
