#!/bin/bash
set -uo pipefail
RED="\e[0;31m"
NC="\e[0m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"

function print_comment(){
    echo -e "$1##########$2###########$NC"
}

function step_status(){
    local rc=$?
    if [ $rc -eq 0 ]
    then
        print_comment $GREEN "$1 step completed successfully"
    else
        print_comment $RED "$1 step is failed"
        exit $rc
    fi
}

# --- MEMORY OPTIMIZATION ---
# Create a 2GB Swap file if it doesn't exist to prevent dnf from hanging
if [ ! -f /swapfile ]; then
    print_comment "$YELLOW" "Creating Swap for memory management"
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile &> /dev/null
    swapon /swapfile
    step_status "Swap Creation"
fi

function copy_service_file(){
    if [ -f $1.service ]
    then
        cp $1.service /etc/systemd/system/$1.service
        step_status "copy $1 service file"
        
    else
        print_comment "$1 service file not found"
        exit 1
    fi
}

function add_appuser(){
    id appuser &> /dev/null
    if [ $? -eq 0 ]
    then
        print_comment "$GREEN" "appuser alredy exists"
    else
        useradd -r -s /bin/false appuser
        step_status "appuser creation"
    fi
    print_comment "$YELLOW" "configure permisison"
    chown -R appuser:appuser /app
    chmod o-rwx /app -R
    step_status "configure permisison"
}

function system_restart(){
    print_comment "$YELLOW" "restart $component_name service"
    systemctl daemon-reload
    systemctl enable $component_name
    systemctl restart $component_name
    step_status "restart $component_name service"
}

function user_build(){
    print_comment "$YELLOW" "Install nodejs"
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &> /dev/null
    dnf install -y nodejs &> /dev/null
    step_status "nodejs installation"
    rm -rf /app
    mkdir -p /app
    add_appuser
    print_comment "$YELLOW" "download $component_name code"
    rm -rf /tmp/$component_name.zip
    curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip &> /dev/null
    step_status "download $component_name code"
    cd /app
    print_comment "$YELLOW" "unzip code"
    unzip /tmp/$component_name.zip &> /dev/null
    step_status "unzip code"
    print_comment "$YELLOW" "install node dependencies"
    npm install --production &> /dev/null
    step_status "install node dependencies"
}

function catalogue_build(){
    print_comment $YELLOW "install golang & msql client"
    dnf install -y golang git mysql8.4 &> /dev/null
    step_status "golang & msql client installation"
    print_comment $YELLOW "download $component_name code"
    rm -rf /tmp/$component_name.zip
    curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip &> /dev/null
    step_status "download $component_name code"
    print_comment $YELLOW "unzip code"
    rm -rf /app
    mkdir -p /app
    cd /app
    unzip /tmp/$component_name.zip &> /dev/null
    step_status "unzip code"
    print_comment $YELLOW "create appuser"
    add_appuser
    cd /app
    print_comment $YELLOW "Build go app"
    go mod tidy &> /dev/null
    CGO_ENABLED=0 go build -o /app/$component_name . &> /dev/null
    step_status "Build Go app"

}

function nginx(){
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

    print_comment $YELLOW "copy nginx conf"
    if [ -f nginx.conf ]
    then 
        cp nginx.conf /etc/nginx/nginx.conf &> /dev/null
    else
        print_comment $RED "nginx.conf is not found"
        exit 1
    fi
}

function frontend_build(){
    print_comment $YELLOW "Install nodejs"
    curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - &> /dev/null
    dnf install -y nodejs &> /dev/null
    step_status "node installation"
    print_comment $YELLOW "Download $component_name source code"
    curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip &> /dev/null
    step_status "Download front end code from remote repo" 
    rm -rf /tmp/$component_name &> /dev/null
    mkdir -p /tmp/$component_name &> /dev/null
    cd /tmp/$component_name
    unzip /tmp/$component_name.zip &> /dev/null
    step_status "unzipping front end code in /tmp" 
    npm cache clean --force &> /dev/null
    npm install &> /dev/null
    step_status "Installing dependencies and libraries"
    npm run build &> /dev/null
    step_status "Building code"
    rm -rf /usr/share/nginx/html/* &> /dev/null
    step_status "remove default code" 
    cp -r out/* /usr/share/nginx/html/ &> /dev/null
    step_status "download front end source code"
    systemctl restart nginx 
    step_status "nginx restart"
}

function shipping_build(){
    print_comment "$YELLOW" "install java,maven,mysql client"
    dnf install -y java-21-openjdk java-21-openjdk-devel maven mysql8.4  &> /dev/null
    step_status "install java,maven,mysql client"
    print_comment "$YELLOW" "download $component_name code"
    rm -rf /tmp/$component_name.zip
    curl -L -o /tmp/$component_name.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/$component_name.zip &> /dev/null
    step_status "download $component_name code"
    rm -rf /app
    mkdir -p /app
    cd /app
    print_comment "$YELLOW" "unzip code"
    unzip /tmp/$component_name.zip &> /dev/null
    step_status "unzip code"
    add_appuser
    cd /app
    print_comment "$YELLOW" "building with maven"
    mvn clean package -DskipTests &> /dev/null
    step_status "building with maven"
    cp target/$component_name.jar /app/$component_name.jar
    step_status "copy jar in /app"
}