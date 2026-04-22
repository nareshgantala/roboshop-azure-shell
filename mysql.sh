# Source the common functions and variables
# This looks for common.sh in the same directory as this script
source "$(dirname "$0")/common.sh"
component_name=mysqld

print_comment $YELLOW "Install MYSQL Server"
dnf install -y mysql8.4-server &> /dev/null
step_status "MYSQL Server installation"


print_comment $YELLOW "restart $component_name"
systemctl enable $component_name &> /dev/null
systemctl restart $component_name &> /dev/null
step_status "restart $component_name"


print_comment $YELLOW "Create Password for user"
mysql -u root -pRoboShop@1 -e "SHOW DATABASES;"
if [ $? -ne 0 ]
then
  mysql -u root -e "
    CREATE USER 'root'@'%' IDENTIFIED BY 'RoboShop@1';
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
    ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';
    FLUSH PRIVILEGES;
  "
  step_status  "password creation"
else
   print_comment $YELLOW "Password is alredy created"
fi