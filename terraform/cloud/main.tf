terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone  = "ru-central1-a"
  token = var.gh_token
}

resource "yandex_compute_disk" "boot-disk-1" {
  name      = "boot-disk-1"
  type      = "network-hdd"
  zone      = "ru-central1-a"
  size      = "20"
  image_id  = "fd83s8u085j3mq231ago"
  folder_id = var.folder_id
}

resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  folder_id = "b1g9819ctjgl6qc4f82c"

  metadata = {
    user-data = "${file("./cloud-config.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name      = "network1"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet-1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  folder_id      = var.folder_id
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}