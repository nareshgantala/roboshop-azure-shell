#!/bin/bash
set -uo pipefail
function print_comment(){
    RED="\e[0;31m"
    NC="\e[0m"
    GREEN="\e[0;32m"
    YELLOW="\e[0;33m"
    echo -e $1##########$2###########$NC
}

function step_status(){
    if [ $? -eq 0 ]
    then
        print_comment $GREEN "$1 step completed successfully"
    else
        print_comment $RED "$1 step is failed"
        exit 1
    fi
}

print_comment $YELLOW "Install nginx webserver"
dnf install -y nginx &> /dev/null
systemctl enable nginx &> /dev/null
systemctl start nginx &> /dev/null
is_nginx_active=$(systemctl is-active nginx)
if [ "$is_nginx_active" = active ]
then
    print_comment $GREEN "nginx installed successfully"
else
    print_comment $RED "nginx installation is failed"
    exit 1
fi


print_comment $YELLOW "Install nodejs"
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &> /dev/null
dnf install -y nodejs &> /dev/null
step_status "node installation"


print_comment $YELLOW "Download frontend source code"
curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/frontend.zip &> /dev/null
step_status "Download front end code from remote repo" 
mkdir -p /tmp/frontend &> /dev/null
cd /tmp/frontend
unzip /tmp/frontend.zip &> /dev/null
step_status "unzipping front end code in /tmp" 
npm install &> /dev/null
step_status "Installing dependencies and libraries"
npm run build &> /dev/null
step_status "Building code"
rm -rf /usr/share/nginx/html/* &> /dev/null
step_status "remove default code" 
cp -r out/* /usr/share/nginx/html/ &> /dev/null
step_status "download front end source code"

print_comment $YELLOW "copy nginx conf"
if [ -f nginx.conf ]
then 
    cp nginx.conf /etc/nginx/nginx.conf &> /dev/null
else
    print_comment $RED "nginx.conf is not found"
    exit 1
fi
    
step_status "copy nginx file"

systemctl restart nginx 
step_status "nginx restart"