#! /bin/bash
set -xe
cat <<EOF > /etc/sausage-store-env
LOG_PATH=/opt/
REPORT_PATH=/opt/logs/reports
EOF
cat <<EOF > ./sausage-store-backend.service
[Unit]
Description=Sausages store backend
After=remote-fs.target network.target

[Service]
EnvironmentFile=/etc/sausage-store-env
WorkingDirectory=/var/jarservice/
StandardOutput=file:/opt/logs/sausage-store.log
SyslogIdentifier=Sausages store backend
User=jarservice
Restart=always
ExecStart=/usr/bin/java \
-Dmyserver.basePath='/home/jarservice/' \
-Dmyserver.bindAddr='127.0.0.1' \
-Dserver.port='8090' \
-Dmyserver.hostName='Sausage-store' \
-jar '/home/jarservice/sausage-store-0.0.1-SNAPSHOT.jar'
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target
EOF
sudo mkdir -p /opt/logs||true
sudo chown -R jarservice:jarusers /opt/logs
sudo cp -rf ./sausage-store-0.0.1-SNAPSHOT.jar /home/jarservice/sausage-store-0.0.1-SNAPSHOT.jar||true
sudo cp -rf ./logrotate_config /etc/logrotate.d/logrotate_config
sudo cp -rf ./sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
sudo systemctl daemon-reload
sudo systemctl restart sausage-store-backend.service
