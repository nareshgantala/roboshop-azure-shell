#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=catalogue
copy_service_file $component_name

print_comment $YELLOW "copy database schema to mysql server"
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/schema.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/app-user.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 $component_name < db/master-data.sql
step_status "copy database schema to mysql server"
go
system_restart
