#Master
resource "yandex_compute_instance" "master" {
  name     = "k8s-master"
  hostname = "master-${var.vpc_name}"
  zone     = var.subnet.k8s-a.zone
  resources {
    cores         = var.vms_resources.master.core
    memory        = var.vms_resources.master.memory
    core_fraction = var.vms_resources.master.fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.k8s-a.id
    nat        = true
    ip_address = "192.168.10.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}

#Worker-1
resource "yandex_compute_instance" "worker-1" {
  name        = "k8s-worker-1"
  hostname    = "worker-${var.vpc_name}-1"
  zone        = var.subnet.k8s-b.zone
  platform_id = "standard-v2"
  resources {
    cores         = var.vms_resources.worker.core
    memory        = var.vms_resources.worker.memory
    core_fraction = var.vms_resources.worker.fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.k8s-b.id
    nat        = true
    ip_address = "192.168.20.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}

#Worker-2
resource "yandex_compute_instance" "worker-2" {
  name        = "k8s-worker-2"
  hostname    = "worker-${var.vpc_name}-2"
  zone        = var.subnet.k8s-d.zone
  platform_id = "standard-v2"
  resources {
    cores         = var.vms_resources.worker.core
    memory        = var.vms_resources.worker.memory
    core_fraction = var.vms_resources.worker.fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.k8s-d.id
    nat        = true
    ip_address = "192.168.30.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}

#Data
data "yandex_compute_image" "ubuntu" {
  family = var.family
}

data "yandex_compute_instance" "master" {
  instance_id = yandex_compute_instance.master.id
}

data "yandex_compute_instance" "worker-1" {
  instance_id = yandex_compute_instance.worker-1.id
}

data "yandex_compute_instance" "worker-2" {
  instance_id = yandex_compute_instance.worker-2.id
}
