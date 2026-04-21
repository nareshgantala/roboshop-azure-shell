#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment $YELLOW "copy catalogue service file"

if [ -f catalougue.service ]
then
    cp catalogue.service /etc/systemd/system/catalogue.service
else
    print_comment "catalogue service file not found"
    exit 1
fi

step_status "copy catalogue service file"

print_comment $YELLOW "install golang & msql client"
dnf install -y golang git mysql8.4 &> /dev/null
step_status "golang & msql client installation"

print_comment $YELLOW "download catalogue code"
rm -rf /tmp/catalogue.zip
curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/catalogue.zip
step_status "download catalogue code"

print_comment $YELLOW "unzip code"
rm -rf /app
mkdir -p /app
cd /app
unzip /tmp/catalogue.zip
step_status "unzip code"

print_comment $YELLOW "copy database schema to mysql server"
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/schema.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/app-user.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 catalogue < db/master-data.sql
step_status "copy database schema to mysql server"


print_comment "create appuser"

id appuser &> /dev/null
if [ $? -ne 0 ]; then
    useradd -r -s /bin/false appuser
    step_status "Appuser creation"
else
    print_comment "$GREEN" "User appuser already exists"
fi

cd /app

print_comment $YELLOW "Build go app"
go mod tidy
CGO_ENABLED=0 go build -o /app/catalogue .
step_status "Build Go app"


print_comment "$YELLOW" "Set permissions"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "Permissions setup"

print_comment $YELLOW "restart catalogue service"
systemctl daemon-reload
systemctl enable catalogue
systemctl restart catalogue
step_status "Restart catalogue service"
