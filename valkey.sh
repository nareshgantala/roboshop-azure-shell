#!/bin/bash
source "$(dirname "$0")/common.sh"

print_comment "$YELLOW" "Install valkey"
dnf install -y valkey &> /dev/null
step_status "valkey installation"

print_comment "$YELLOW" "upte bind to 0.0.0.0"
sed -i "s/bind 127.0.0.1/bind 0.0.0.0/" /etc/valkey/valkey.conf
step_status "bind to 0.0.0.0"

print_comment "$YELLOW" "no to protected mode"
sed -i "s/protected-mode yes/protected-mode no/" /etc/valkey/valkey.conf
step_status "no to protect mode"

print_comment "$YELLOW" "restart valkey"
systemctl enable valkey
systemctl restart valkey
step_status "valkey restart"