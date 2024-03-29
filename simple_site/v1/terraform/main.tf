terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_network" "vnet" {
  name = "vnetwork"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "vsubnet" {
  v4_cidr_blocks =["10.0.1.0/25"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vnet.id}"
  folder_id = var.folder_id

}

resource "yandex_compute_instance" "machine" {
  name        = "frontend-from-tf"
  folder_id = var.folder_id
  platform_id = "standard-v3"
  allow_stopping_for_update = true
  zone = "ru-central1-a"
  resources {
    cores  = 2
    memory = 2
  }
  
  metadata = {
     ssh-keys = "ubuntu:${file("${var.ssh_pub_key_path}")}"
  }
 
  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.vsubnet.id}"
    nat = true
  }
}

variable "folder_id" {
  type = string
  default = "b1g2cqilh48vlvlik6ug" # test-catalog
}

variable "image_id" {
  type = string
  default = "fd8g5aftj139tv8u2mo1" # https://cloud.yandex.ru/marketplace/products/yc/ubuntu-22-04-lts
}

variable "ssh_pub_key_path" {
  type = string
  default = "~/.ssh/id_rsa_ycloud.pub"
}

output "vm_address" {
  value = yandex_compute_instance.machine.network_interface[0].nat_ip_address
}