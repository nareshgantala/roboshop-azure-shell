print_comment "$YELLOW" "install java,maven,mysql client"
dnf install -y java-21-openjdk java-21-openjdk-devel maven mysql8.4
step_status "install java,maven,mysql client"

if [ -f shipping.service ]
then
    print_comment "copying shipping service file"
    cp shipping.service /etc/systemd/system/shipping.service
    step_status "copy shipping service file"
else
    print_comment "$RED" "shipping service file doesnot exist"
    exit 1
fi

print_comment "$YELLOW" "download shipping code"
rm -rf /tmp/shipping.zip
curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/shipping.zip
step_status "download shipping code"

rm -rf /app
mkdir -p /app
cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/shipping.zip
step_status "unzip code"

print_comment "$YELLOW" "database configuration"
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/schema.sql
mysql -h <MYSQL-SERVER-IP> -u root -pRoboShop@1 < db/app-user.sql
step_status "database configuration"


id appuser &> /dev/null
if [ $? -eq 0 ]
then
    print_comment "$GREEN" "appuser alredy exists"
else
    useradd -r -s /bin/false appuser
    step_status  "appuser creation"
fi

cd /app

print_comment "$YELLOW" "building with maven"
mvn clean package -DskipTests
step_status "building with maven"


cp target/shipping.jar /app/shipping.jar
step_status "copy jar in /app"

print_comment "$YELLOW" "permissions config for appuser"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "permissions config for appuser"

print_comment "$YELLOW" "restart shipping service"
systemctl daemon-reload
systemctl enable shipping
systemctl restart shipping
step_status "restart shipping service"