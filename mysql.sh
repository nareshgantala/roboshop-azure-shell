#!/bin/bash
set -uo pipefail
RED="\e[0;31m"
GREEN="\e[0;32m"
YELLOW="\e[0;33m"
NC="\e[0m"
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

print_comment $YELLOW "Install MYSQL Server"
dnf install -y mysql8.4-server
step_status "MYSQL Server installation"


print_comment $YELLOW "restart mysqld"
systemctl enable mysqld
systemctl restart mysqld
step_status "restart mysqld"


print_comment $YELLOW "Create Password for user"
mysql -u root -e "
  CREATE USER 'root'@'%' IDENTIFIED BY 'RoboShop@1';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';
  FLUSH PRIVILEGES;
"
step_status "Password creation for user"


