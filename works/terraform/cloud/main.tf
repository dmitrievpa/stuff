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
    bucket     = "<backet_name>"
    region     = "ru-central1"
    key        = "./terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
resource "yandex_vpc_network" "vpc-network" {
  name = "VPN"
}
resource "yandex_vpc_subnet" "vpc-subnet" {
  name           = "subnet-1"
  description    = "VPN subnet"
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = var.zone
  network_id     = "${yandex_vpc_network.vpc-network.id}"
  depends_on = [
    yandex_vpc_network.vpc-network,
  ]
}
resource "yandex_compute_instance" "meket-infra" {
  provider = yandex
  count    = length(var.vm_name)
  name     = var.vm_name[count.index]


  resources {
    cores  = 2
    memory = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.image
      size = 35
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.vpc-subnet.id
    nat       = true
  }
  scheduling_policy {
      preemptible = false
    }
  metadata = {
    serial-port-enable = "1"
    user-data = "${file("./files/users.txt")}"
  }
}
resource "yandex_vpc_security_group" "vpc-public-services" {
  name        = "vpc-public-services"
  description = "Правила группы разрешают подключение к сервисам из интернета. Примените правила только для групп узлов."
  network_id  = yandex_vpc_network.vpc-network.id
  ingress {
    protocol          = "ANY"
    description       = "Правило разрешает взаимодействие внутри подсети."
    v4_cidr_blocks    = yandex_vpc_subnet.vpc-subnet.v4_cidr_blocks
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "Правило разрешает отладочные ICMP-пакеты из внутренних подсетей."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol       = "TCP"
    description    = "Правило разрешает входящий трафик из интернета для подключения к ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
  egress {
    protocol          = "ANY"
    description       = "Правило разрешает весь исходящий трафик."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}