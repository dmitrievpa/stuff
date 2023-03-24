#! /bin/bash
set -xe
cat <<EOF > ./sausage-store-frontend.service
[Unit]
Description=Sausages store frontend
After=remote-fs.target network.target sausage-store-backend.service

[Service]
WorkingDirectory=/var/www-data/dist/frontend/
ExecStart=/usr/bin/http-server -p 8081 --proxy http://localhost:8090
StandardOutput=file:/logs/out-front.log
SyslogIdentifier=Sausages store frontend
User=front-user
Restart=always

[Install]
WantedBy=multi-user.target
EOF
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store-frontend.tar.gz ${NEXUS_REPO_URL}-frontend/sausage-store/${VERSION}/sausage-store-${VERSION}.tar.gz
cd /var/www-data/
sudo tar -zxvf /home/deployer/sausage-store-frontend.tar.gz  --strip-components=1 frontend/
sudo cp -rf /home/deployer/sausage-store-frontend.service /etc/systemd/system/sausage-store-frontend.service
sudo systemctl daemon-reload
sudo systemctl restart sausage-store-frontend.service
