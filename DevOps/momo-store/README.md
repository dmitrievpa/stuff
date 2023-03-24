# Momo Store aka Пельменная №2

<img width="900" alt="image" src="https://user-images.githubusercontent.com/9394918/167876466-2c530828-d658-4efe-9064-825626cc6db5.png">

## Application
https://momo-store.mangoit.me
## Monitoring
https://grafana.mangoit.me

login: readonly/readonly


Production monitoring: https://grafana.mangoit.me/d/efa86fd1d0c121a26444b636a3f509a8/kubernetes-compute-resources-cluster?orgId=1&refresh=10s

Logs: https://grafana.mangoit.me/d/JCCCN22Vz/momo-store-logs?orgId=1

## Deployment
https://argocd.mangoit.me

## Repository structure

```
.
├── README.md
├── backend - backend sources
├── frontend - frontend sources
└── .gitlab-ci.yml
```

## Frontend
### Requirements
NodeJS v16.13.2

```bash
npm install
NODE_ENV=production VUE_APP_API_URL=http://localhost:8081 npm run serve
```

## Backend
golang v1.19


```bash
go run ./cmd/api
go test -v ./... 
```
## Predefined variables
### All variables required and should defined before run CI/CD processes
1. ARGO_SERVER - ArgoCD server FQDN
2. ARGO_USER - ArgoCD server deploy user
3. DOCKER_USER - Gitlab user for docker registry
4. DOCKER_TOKEN - Auth token for $DOCKER_USER
5. FRONTEND_VERSION - ${VERSION}-${CI_COMMIT_BRANCH} (default: latest)
6. BACKEND_VERSION - ${VERSION}-${CI_COMMIT_BRANCH} (default: latest)
7. GITLAB_ACCESS_TOKEN - Gitlab API auth token
8. K8S_CLUSTER_NAME - k8s cluster name (default: k8s-momo-store)
9. NEXUS_REPO_USER - Sonatype NEXUS repo user
10. NEXUS_REPO_PASS - Sonatype NEXUS repo passsword
11. NEXUS_REPO_URL - Sonatype NEXUS repo URL
12. SONARQUBE_URL - Sonarqube url
13. SONAR_BACKEND_PROJECT_KEY Sonarqube project key
14. SONAR_BACKEND_TOKEN Sonarqube project token
15. SONAR_FRONTEND_PROJECT_KEY Sonarqube project token
16. SONAR_FRONTEND_TOKEN Sonarqube project token
17. YC_CLOUD_ID - Yandex cloud ID
18. YC_FOLDER_ID - Yandex cloud deployment folder ID
19. YC_TOKEN - Yandex cloud profile token
## How to make a change
1. Create a branch from master
2. Push changes
3. Submit a pull request

## Infrastructure

### Repository
1. https://gitlab.praktikum-services.ru/p.dmitriev/momo-store-infra
- terraform + YC
- managed k8s
- s3 bucket for data
- ArgoCD
- Loki + Promtail + Grafana = logs collection/monitoring
- Prometheus + Grafana = metrics collection

## Versioning
### Docker images
See VERSION variable in *.gitlab-ci.yml
- backend: VERSION: 1.0.${CI_PIPELINE_ID}
- frontend: VERSION: 1.0.${CI_PIPELINE_ID}

An image tag template:
${VERSION}-$CI_COMMIT_BRANCH
e.g. 
- 1.0.368120-dev
gitlab.praktikum-services.ru:5050/p.dmitriev/momo-store/momo-store-backend:1.0.368120-dev