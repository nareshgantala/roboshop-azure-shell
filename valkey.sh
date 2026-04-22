#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=valkey

print_comment "$YELLOW" "Install $component_name"
dnf install -y $component_name &> /dev/null
step_status "$component_name installation"

print_comment "$YELLOW" "upte bind to 0.0.0.0"
sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/$component_name/$component_name.conf
step_status "bind to 0.0.0.0"

print_comment "$YELLOW" "no to protected mode"
sed -i "s/protected-mode yes/protected-mode no/" /etc/$component_name/$component_name.conf
step_status "no to protect mode"

system_restart