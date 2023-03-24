#!/bin/bash
set +e
cat > .env <<EOF
REPORT_PATH=/app/reports/
SPRING_CLOUD_VAULT_TOKEN=${SPRING_CLOUD_VAULT_TOKEN}
EOF
sudo usermod -aG docker ${DEV_USER}
echo $DOCKER_TOKEN | docker login -u $DOCKER_USER --password-stdin $CI_REGISTRY
docker pull $CI_REGISTRY_IMAGE/sausage-backend:latest
docker network create -d bridge sausage_network || true
docker stop backend || true
docker rm backend || true
set -e
docker run -d --name backend \
    --network=sausage_network \
    --restart always \
    --pull always \
    --env-file .env \
    $CI_REGISTRY_IMAGE/sausage-backend:latest