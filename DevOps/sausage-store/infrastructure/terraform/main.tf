terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

resource "yandex_compute_instance" "vms-test" {
  provider = yandex
  count    = length(var.vm_name)
  name     = var.vm_name[count.index]


  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd82re2tpfl4chaupeuf"
      size = 30
    }
  }

  network_interface {
    subnet_id = "e2l4ck13qo52mn9ue7b0"
    nat       = true
  }
  metadata = {
    user-data = "${file("./files/ansible_user.txt")}"
  }
}