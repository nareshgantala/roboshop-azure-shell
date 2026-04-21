#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "create rabbitmq-erlang repo"
cat > /etc/yum.repos.d/rabbitmq_erlang.repo << 'EOF'
[rabbitmq_erlang]
name=rabbitmq_erlang
baseurl=https://packagecloud.io/rabbitmq/erlang/el/9/$basearch
gpgcheck=0
enabled=1
EOF
step_status "create rabbiymq repo"

print_comment "$YELLOW" "install erlang"
dnf install -y erlang > /dev/null
step_status "install erlang"


print_comment "$YELLOW" "create rabbitmq-server repo"
cat > /etc/yum.repos.d/rabbitmq_rabbitmq-server.repo << 'EOF'
[rabbitmq_rabbitmq-server]
name=rabbitmq_rabbitmq-server
baseurl=https://packagecloud.io/rabbitmq/rabbitmq-server/el/9/$basearch
gpgcheck=0
enabled=1
EOF
step_status "create rabbitmq-server repo"

print_comment "$YELLOW" "install rabbitmq server"
dnf install -y rabbitmq-server > /dev/null
step_status "install rabbitmq server"

print_comment "$YELLOW" "restart rabbitmq"
systemctl enable rabbitmq-server > /dev/null
systemctl start rabbitmq-server
step_status "restart rabbitmq server"

rabbitmqctl list_users | grep roboshop &> /dev/null

if [ $? -ne 0 ]
then
    rabbitmqctl add_user roboshop RoboShop@1 > /dev/null
    rabbitmqctl set_user_tags roboshop administrator > /dev/null    
    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" > /dev/null    
    step_status "rabbitmq user config"
else
    print_comment "$GREEN" "RabbitMQ user 'roboshop' already exists"
fi

