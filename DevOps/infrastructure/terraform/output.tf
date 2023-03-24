output "k8s_master_external_ip_address" {
  value = yandex_kubernetes_cluster.k8s-cluster.master[0].external_v4_address
}
output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.k8s-cluster.id
}
output "k8s_cluster_name" {
  value = yandex_kubernetes_cluster.k8s-cluster.name
}
