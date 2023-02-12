terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_token
  cloud_id  = "b1g0fbvh9vhtg8cltrcf"
  folder_id = "b1gqjc542bmr5l4gip40"
  #  zone      = "ru-central1-a"
}

#resource "yandex_vpc_subnet" "subnet-1" {
#  id             = "e9bku4tfppegiea22163"
#  name           = "subnet1"
#  route_table_id = "enpl1vfliv1p2f4k41sr"
#  # (7 unchanged attributes hidden)
#}

resource "yandex_compute_instance" "vm-1" {
  name                      = "web1"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
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

resource "yandex_compute_instance" "vm-2" {
  name                      = "web2"
  zone                      = "ru-central1-b"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8emvfmfoaordspe1jr"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-3.id
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
  name                      = "prome"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
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

resource "yandex_compute_instance" "vm-5" {
  name                      = "grafana"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fhgufmvsgqk4r1h24"
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

resource "yandex_compute_instance" "vm-6" {
  name                      = "elasticsearch"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fhgufmvsgqk4r1h24"
      size     = 5
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

resource "yandex_compute_instance" "vm-7" {
  name                      = "kibana"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fhgufmvsgqk4r1h24"
      size     = 5
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

resource "yandex_compute_instance" "vm-8" {
  name                      = "jump"
  zone                      = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
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
    security_group_ids = [yandex_vpc_security_group.test-sg.id]
  }

  metadata = {
    user-data = "${file("~/yandex_terraform/meta.txt")}"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" { #internal
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  folder_id      = "b1gqjc542bmr5l4gip40"
  name           = "subnet2"
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  route_table_id = "enpl1vfliv1p2f4k41sr"
}

#resource "yandex_vpc_subnet" "subnet-2" { #external network
#  name           = "subnet2"
#  zone           = "ru-central1-b"
#  network_id     = yandex_vpc_network.network-1.id
#  v4_cidr_blocks = ["192.168.20.0/24"]
#}

resource "yandex_vpc_subnet" "subnet-3" { #internal
  name           = "subnet3"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.30.0/24"]
  route_table_id = "enpl1vfliv1p2f4k41sr"
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm-1.network_interface.0.ip_address
}

output "internal_ip_address_vm_2" {
  value = yandex_compute_instance.vm-2.network_interface.0.ip_address
}

output "external_ip_address_vm_8" {
  value = yandex_compute_instance.vm-8.network_interface.0.nat_ip_address
}

output "external_ip_address_vm_7" {
  value = yandex_compute_instance.vm-7.network_interface.0.nat_ip_address
}

resource "yandex_alb_target_group" "foo" {
  name = "netology"

  target {
    subnet_id  = yandex_vpc_subnet.subnet-2.id
    ip_address = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.subnet-3.id
    ip_address = yandex_compute_instance.vm-2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "netology-backend-group" {
  name = "netology"

  http_backend {
    name             = "netology"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.foo.id]
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
        backend_group_id = yandex_alb_backend_group.netology-backend-group.id
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
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
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
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
}
