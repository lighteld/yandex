terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  //token     = "AQAAAAAA-wnHAATuwXUAadRYcku5h2Zrlc4-Pi0"
  token	    =  var.yandex_token
  cloud_id  = "b1g0fbvh9vhtg8cltrcf"
  folder_id = "b1gqjc542bmr5l4gip40"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "web1"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
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

resource "yandex_compute_instance" "vm-2" {
  name = "web2"
  zone = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = false
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-3" {
  name = "prome"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-4" {
  name = "ansible"
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
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = false
  }

  scheduling_policy {
    preemptible = true
  }

   metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_compute_instance" "vm-8" {
  name = "jump"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

output "yandex_vpc_subnet_2" {
  value = yandex_vpc_subnet.subnet-2.id
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address
}

resource "yandex_alb_target_group" "foo" {
  name = "netology"

  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address = "${yandex_compute_instance.vm-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id  = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address = "${yandex_compute_instance.vm-2.network_interface.0.ip_address}"
  }
}

resource "yandex_alb_backend_group" "netology-backend-group" {
  name = "netology"

  http_backend {
    name             = "netology"
    weight           = 1
    port             = 80
    target_group_ids = ["ds7odbibro1ddffq3694"]
    load_balancing_config {
      panic_threshold = 90
    }
    healthcheck {
      timeout             = "10s"
      interval            = "2s"
      healthy_threshold   = 10
      unhealthy_threshold = 15
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name = "netology"
  labels = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "control"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "netology"
    http_route {
      http_route_action {
        backend_group_id = "ds7qphb06n6nfdhji931"
        timeout          = "3s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "test-balancer" {
  name       = "balance"
  network_id = "enpt6gjfrig934r5demr"

  allocation_policy {
    location {
      zone_id   = "ru-central1-b"
      subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    }
  }

  listener {
    name = "balancer"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = "ds7k3s8kq512eslgs6te"
      }
    }
  }
}
