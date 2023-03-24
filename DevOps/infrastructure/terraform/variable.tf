variable "cloud_id" {
  type = string
  default = "b1gd0k9h37qeqgl999hs"
}
variable "folder_id" {
  type = string
  default = "b1goilgmr2dfcq0akkrm"
}
variable "zone" {
  type = string
  default = "ru-central1-b" 
}
variable "k8s_version" {
  type = string
  default = "1.22"
}
variable "sa_name" {
  type = string
  default = "k8sadm"
}
variable "dns_domain" {
  type = string
  default = "mangoit.me"
}
variable "app_dns_name" {
  type = string
  default = "momo-store.mangoit.me"
}
variable "argocd_dns_name" {
  type = string
  default = "argocd.mangoit.me"
}
variable "grafana_dns_name" {
  type = string
  default = "grafana.mangoit.me"
}
variable "repository_username" {
  type = string
  description = "Nexus repository username"
}
variable "repository_password" {
  type = string
  description = "Nexus repository password"
}
