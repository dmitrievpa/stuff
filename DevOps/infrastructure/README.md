# Momo Store aka Пельменная №2 Infrastructure

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
├── argo-cd-chart - ArgoCD sources
├── monitoring - grafana/prometheus/loki sources
├── terraform - terraform sources
├── argocd.gitlab-ci.yml
├── momo-store-backend.gitlab-ci.yml - deploy backend triggered from application repository (https://gitlab.praktikum-services.ru/p.dmitriev/momo-store)
├── momo-store-frontend.gitlab-ci.yml - deploy frontend triggered from application repository (https://gitlab.praktikum-services.ru/p.dmitriev/momo-store)
└── .gitlab-ci.yml - upstream pipeline for trigger downstream jobs
```

## Predefined variables
### All variables required and should defined before run CI/CD processes
1. ARGO_SERVER - ArgoCD server FQDN
2. ARGO_USER - ArgoCD server deploy user
3. K8S_CLUSTER_NAME - k8s cluster name (default: k8s-momo-store)
4. NEXUS_REPO_USER - Sonatype NEXUS repo user
5. NEXUS_REPO_PASS - Sonatype NEXUS repo passsword
6. NEXUS_REPO_INFRA_URL - Sonatype NEXUS repo URL for ArgoCD chart
7. TF_S3_ACCESSKEY - S3 Object storage access key (for tfstate file)
8. TF_S3_BUCKET - S3 Object storage bucket name (for tfstate file)
9. TF_S3_KEY - S3 Object storage file name (for tfstate file)
10. TF_S3_SECRETKEY S3 Object storage access key (for tfstate file)
11. TF_VAR_repository_password = NEXUS_REPO_PASS
12. TF_VAR_repository_username = NEXUS_REPO_USER
17. YC_CLOUD_ID - Yandex cloud ID
18. YC_FOLDER_ID - Yandex cloud deployment folder ID
19. YC_TOKEN - Yandex cloud profile token


## Infrastructure deployment tasks sequence

### Repository https://gitlab.praktikum-services.ru/p.dmitriev/momo-store-infra
1. Install infrastructure deployment from terraform/.gitlab-ci.yml
  - YC managed k8s
  - YC VPC
  - YC Compute cloud
  - YC Cloud DNS
  - YC Network balancer 
  - Ingress Nginx
  - Cert manager
  - ArgoCD
2. Install ArgoCD application from ./argocd.gitlab-ci.yml (manual). Default image tag "latest"
3. Install Loki stack and Prometheus stack with grafana  


### How to make a change

All changes should be done with code!

1. Create a branch
2. Push changes
3. Submit a pull request


## Versioning
### Helm chart
See HELM_VERSION variable in *.gitlab-ci.yml
- variables: HELM_VERSION: 1.0.${CI_PIPELINE_ID}
e.g 1.0.367456