#terraform {
#  required_providers {
#    yandex = {
#      source = "yandex-cloud/yandex"
#    }
#  }

resource "yandex_compute_instance" "vm-6" {
  name = "elasticsearch"
  zone = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fhgufmvsgqk4r1h24"
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false
  }

   scheduling_policy {
    preemptible = true
  }

   metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-7" {
  name = "kibana"
  zone = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fhgufmvsgqk4r1h24"
      size = 5
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = true
  }

   scheduling_policy {
    preemptible = true
  }

   metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}
