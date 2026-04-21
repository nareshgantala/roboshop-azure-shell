#!/bin/bash
source "$(dirname "$0")/common.sh"

if [ -f mongo.repo ]
then
    cp mongo.repo /etc/yum.repos.d/mongodb-org-7.0.repo
    step_status "Copy mongo repo file"
else
    print_comment $RED "mongo repo file doesn't exist"
    exit 1
fi

print_comment $YELLOW "install mongodb"
dnf install -y mongodb-org &> /dev/null
sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
step_status "mongodb installation"

print_comment $YELLOW "restart mongodb"
systemctl enable mongod
systemctl restart mongod
step_status "mongodb restart"
