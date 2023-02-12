resource "yandex_vpc_security_group" "test-sg" {
  name        = "allow ssh"
  description = "SSH and web for balancer"
  network_id  = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "TCP"
    description    = "allow ssh"
    v4_cidr_blocks = ["192.168.10.0/24","192.168.20.0/24","192.168.30.0/24"]
    from_port           = 22
    to_port = 22
  }
}

resource "yandex_vpc_security_group" "allow_kibana" {
  name        = "allow kibana grafana"
  description = "SSH and web for balancer"
  network_id  = "enpt6gjfrig934r5demr"

  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }
  ingress {
    protocol       = "TCP"
    description    = "Rule description 1"
    v4_cidr_blocks = ["192.168.20.28/32"]
    port           = 22
  }
}

