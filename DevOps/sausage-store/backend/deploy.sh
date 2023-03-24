#! /bin/bash
set -xe
cat <<EOF > /etc/sausage-store-env
REPORT_PATH=/opt/sausage-store/backend/reports/
EOF

echo "PSQL_HOST=$PSQL_HOST" >> /etc/sausage-store-env
echo "PSQL_PORT=$PSQL_PORT" >> /etc/sausage-store-env
echo "PSQL_DBNAME=$PSQL_DBNAME" >> /etc/sausage-store-env
echo "PSQL_USER=$PSQL_USER" >> /etc/sausage-store-env
echo "PSQL_PASSWORD=$PSQL_PASSWORD" >> /etc/sausage-store-env
echo "MONGO_HOST=$MONGO_HOST" >> /etc/sausage-store-env
echo "MONGO_PORT=$MONGO_PORT" >> /etc/sausage-store-env
echo "MONGO_DATABASE=$MONGO_DATABASE" >> /etc/sausage-store-env
echo "MONGO_USER=$MONGO_USER" >> /etc/sausage-store-env
echo "MONGO_PASSWORD=$MONGO_PASSWORD" >> /etc/sausage-store-env

cat <<EOF > ./sausage-store-backend.service
[Unit]
Description=Sausages store backend
After=remote-fs.target network.target

[Service]
EnvironmentFile=/etc/sausage-store-env
WorkingDirectory=/opt/sausage-store/backend/lib/
StandardOutput=append:/opt/sausage-store/backend/log/out.log
StandardError=append:/opt/sausage-store/backend/log/error.log
SyslogIdentifier=Sausages store backend
User=jarservice
Restart=always
ExecStart=/usr/bin/java \
-Dmyserver.basePath='/home/jarservice/' \
-Dmyserver.bindAddr='127.0.0.1' \
-Dserver.port='8090' \
-Dmyserver.hostName='Sausage-store' \
-Dspring.datasource.username=${PSQL_USER} \
-Dspring.datasource.password=${PSQL_PASSWORD} \
-Dspring.datasource.url=jdbc:postgresql://${PSQL_HOST}:${PSQL_PORT}/${PSQL_DBNAME} \
-Dspring.data.mongodb.uri=mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DATABASE}?tls=true&replicaSet=rs01 \
-jar '/opt/sausage-store/backend/lib/sausage-store.jar'
SuccessExitStatus=143
[Install]
WantedBy=multi-user.target
EOF
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}-backend/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
sudo cp -rf ./sausage-store.jar /opt/sausage-store/backend/lib/sausage-store.jar||true
sudo cp -rf ./sausage-store-backend.service /etc/systemd/system/sausage-store-backend.service
sudo systemctl daemon-reload
sudo systemctl restart sausage-store-backend.service
