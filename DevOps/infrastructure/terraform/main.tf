terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
  #Cannot use variables (See: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#literal-values-only)
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
resource "yandex_kubernetes_cluster" "k8s-cluster" {
  network_id = yandex_vpc_network.k8s_net.id
  name = "k8s-momo-store"
  master {
    version = var.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.k8s_subnet.zone
      subnet_id = yandex_vpc_subnet.k8s_subnet.id
    }
    security_group_ids = [yandex_vpc_security_group.k8s-public-services.id]
  public_ip = true
  }
  service_account_id      = yandex_iam_service_account.myaccount.id
  node_service_account_id = yandex_iam_service_account.myaccount.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
}
resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = "main"
  description = "Momo Store Node Group"
  version     = var.k8s_version
  instance_template {
    platform_id = "standard-v3"
    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.k8s_subnet.id]
    }
    resources {
      cores         = 2
      memory        = 4
      core_fraction = 50
    }
    boot_disk {
      type = "network-hdd"
      size = 32
    }
    scheduling_policy {
      preemptible = false
    }
    metadata = {
      ssh-keys = "ubuntu:${file("./files/deployer_rsa.pub")}"
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-b"
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "01:00"
      duration   = "3h"
    }
  }
}
resource "yandex_vpc_network" "k8s_net" {
  name = "k8s_net"
}

resource "yandex_vpc_subnet" "k8s_subnet" {
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s_net.id
  depends_on = [
    yandex_vpc_network.k8s_net,
  ]
}
resource "yandex_vpc_address" "addr" {
  name = "static-ip"
  external_ipv4_address {
    zone_id = "ru-central1-b"
  }
}

resource "yandex_iam_service_account" "myaccount" {
  name        = var.sa_name
  description = "K8S zonal service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}
resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}",
  ]
}
resource "yandex_dns_zone" "dns_domain" {
  name   = replace(var.dns_domain, ".", "-")
  zone   = join("", [var.dns_domain, "."])
  public = true
}
resource "yandex_dns_recordset" "momo-store_dns_domain" {
  zone_id = yandex_dns_zone.dns_domain.id
  name    = join("", [var.app_dns_name, "."])
  type    = "A"
  ttl     = 200
  data    = [yandex_vpc_address.addr.external_ipv4_address[0].address]
}
resource "yandex_dns_recordset" "argocd_dns_domain" {
  zone_id = yandex_dns_zone.dns_domain.id
  name    = join("", [var.argocd_dns_name, "."])
  type    = "A"
  ttl     = 200
  data    = [yandex_vpc_address.addr.external_ipv4_address[0].address]
}
resource "yandex_dns_recordset" "grafana_dns_domain" {
  zone_id = yandex_dns_zone.dns_domain.id
  name    = join("", [var.grafana_dns_name, "."])
  type    = "A"
  ttl     = 200
  data    = [yandex_vpc_address.addr.external_ipv4_address[0].address]
}
resource "yandex_vpc_security_group" "k8s-public-services" {
  name        = "k8s-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.k8s_net.id
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает проверки доступности с диапазона адресов балансировщика нагрузки. Нужно для работы отказоустойчивого кластера и сервисов балансировщика."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие мастер-узел и узел-узел внутри группы безопасности."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие под-под и сервис-сервис. Укажите подсети вашего кластера и сервисов."
    v4_cidr_blocks    = yandex_vpc_subnet.k8s_subnet.v4_cidr_blocks
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Правило разрешает входящий трафик из интернета на диапазон портов NodePort. Добавьте или измените порты на нужные вам."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета к API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета к API"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик. Узлы могут связаться с Yandex Container Registry, Yandex Object Storage, Docker Hub и т. д."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}