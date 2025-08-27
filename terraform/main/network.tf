#VPC
resource "yandex_vpc_network" "kubernetes" {
  name = var.vpc_name
}

#Subnets
resource "yandex_vpc_subnet" "k8s-a" {
  name           = var.subnet.k8s-a.name
  zone           = var.subnet.k8s-a.zone
  network_id     = yandex_vpc_network.kubernetes.id
  v4_cidr_blocks = var.subnet.k8s-a.cidr
}

resource "yandex_vpc_subnet" "k8s-b" {
  name           = var.subnet.k8s-b.name
  zone           = var.subnet.k8s-b.zone
  network_id     = yandex_vpc_network.kubernetes.id
  v4_cidr_blocks = var.subnet.k8s-b.cidr
}

resource "yandex_vpc_subnet" "k8s-d" {
  name           = var.subnet.k8s-d.name
  zone           = var.subnet.k8s-d.zone
  network_id     = yandex_vpc_network.kubernetes.id
  v4_cidr_blocks = var.subnet.k8s-d.cidr
}

resource "yandex_vpc_subnet" "test-actions" {
  name           = "test-actions1"
  zone           = var.subnet.k8s-d.zone
  network_id     = yandex_vpc_network.kubernetes.id
  v4_cidr_blocks = var.subnet.k8s-d.cidr
}
