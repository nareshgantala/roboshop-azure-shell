#!/bin/bash
source "$(dirname "$0")/common.sh"
component_name=shipping
copy_service_file shipping
shipping_build
print_comment "$YELLOW" "database configuration"
mysql -h mysql.naresh-training.online -u root -pRoboShop@1 < db/schema.sql
mysql -h mysql.naresh-training.online -u root -pRoboShop@1 < db/app-user.sql
step_status "database configuration"
system_restart