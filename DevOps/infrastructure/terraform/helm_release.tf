provider "helm" {
  kubernetes {
    host                   = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_endpoint
    cluster_ca_certificate = yandex_kubernetes_cluster.k8s-cluster.master[0].cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["k8s", "create-token"]
      command     = "yc"
    }
  }
}
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.2.1"
  wait       = true
  depends_on = [
    yandex_kubernetes_node_group.k8s_node_group
  ]
  set {
    name  = "controller.service.loadBalancerIP"
    value = yandex_vpc_address.addr.external_ipv4_address[0].address
  }
}
resource "helm_release" "cert-manager" {
  namespace        = "cert-manager"
  create_namespace = true
  name             = "jetstack"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v1.10.1"
  wait             = true
  depends_on = [
    yandex_kubernetes_node_group.k8s_node_group
  ]
  set {
    name  = "installCRDs"
    value = true
  }
}
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true
  repository = "https://nexus.praktikum-services.ru/repository/07-p.dmitriev-momo-store-infra/"
  repository_username = var.repository_username
  repository_password = var.repository_password
  chart      = "argo-cd"
  version    = "4.5.3-1"
  wait       = true
  depends_on = [
    yandex_kubernetes_node_group.k8s_node_group
  ]
}