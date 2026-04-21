print_comment "$YELLOW" "Install nodejs"
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs &> /dev/null
step_status "nodejs installation"

if [ -f cart.service ]
then
    cp cart.service /etc/systemd/system/cart.service
    step_status "cart service file copy"
else
    print_comment "$RED" "cart service file doesnot exist"
fi

id appuser &> /dev/null
if [ $? -eq 0 ]
then
    print_comment "$GREEN" "appuser alredy exists"
else
    useradd -r -s /bin/false appuser
    print_comment "$GREEN" "appuser has been created"
fi

rm -rf /app
mkdir -p /app

print_comment "$YELLOW" "download cart code"
rm -rf /tmp/cart.zip
curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/cart.zip
step_status "download cart code"
cd /app

print_comment "$YELLOW" "unzip code"
unzip /tmp/cart.zip
step_status "unzip code"

print_comment "$YELLOW" "install node dependencies"
npm install --production
step_status "install node dependencies"

print_comment "$YELLOW" "configure permissions for appuser"
chown -R appuser:appuser /app
chmod o-rwx /app -R
step_status "Permissions setup"

print_comment "$YELLOW" "restart cart service"
systemctl daemon-reload
systemctl enable cart
systemctl restart cart
step_status "restart cart service"
