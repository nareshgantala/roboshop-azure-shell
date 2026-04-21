curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
dnf install -y nodejs
node --version
npm --version

useradd -r -s /bin/false appuser
mkdir -p /app

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/raghudevopsb89/roboshop-microservices/main/artifacts/user.zip
cd /app
unzip /tmp/user.zip
npm install --production
chown -R appuser:appuser /app
chmod o-rwx /app -R

systemctl daemon-reload
systemctl enable user
systemctl start user