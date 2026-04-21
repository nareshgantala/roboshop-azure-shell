#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "install python,mysql client"
dnf install -y python3 python3-pip mysql8.4
step_status "install python,mysql client"

if [ -f ratings.service ]
then
    print_comment "copying shipping service file"
    cp ratings.service /etc/systemd/system/ratings.service
    step_status "copy ratings service file"
else
    print_comment "$RED" "ratings service file doesnot exist"
    exit 1
fi

print_comment "$YELLOW" "download ratings code"
rm -rf /tmp/ratings.zip
curl -L -o /tmp/ratings.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/ratings.zip
step_status "download ratings code"
rm -rf /app
mkdir -p /app && cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/ratings.zip
step_status "unzip code"

print_comment "$YELLOW" "database config"
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/schema.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/app-user.sql
step_status "database config"

id appuser &> /dev/null
if [ $? -eq 0 ]
then
    print_comment "$GREEN" "appuser alredy exists"
else
    useradd -r -s /bin/false appuser
    step_status "appuser creation"
fi

print_comment "$YELLOW" "install dependencies"
pip3 install -r /app/requirements.txt cryptography
step_status "install dependencies"

print_comment "$YELLOW" "configure permissions"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "configure permissions"

print_comment "$YELLOW" "restart ratings service"
systemctl daemon-reload
systemctl enable ratings
systemctl start ratings
step_status "restart ratings service"