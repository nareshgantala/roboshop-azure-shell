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
}