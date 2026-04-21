# Source the common functions and variables
# This looks for common.sh in the same directory as this script
source "$(dirname "$0")/common.sh"

print_comment $YELLOW "Install MYSQL Server"
dnf install -y mysql8.4-server &> /dev/null
step_status "MYSQL Server installation"


print_comment $YELLOW "restart mysqld"
systemctl enable mysqld &> /dev/null
systemctl restart mysqld &> /dev/null
step_status "restart mysqld"


print_comment $YELLOW "Create Password for user"
mysql -u root -e "
  CREATE USER 'root'@'%' IDENTIFIED BY 'RoboShop@1';
  GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
  ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';
  FLUSH PRIVILEGES;
"
step_status "Password creation for user"


