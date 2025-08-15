#HAProxy
resource "yandex_compute_instance" "ha-proxy" {
  name        = "ha-proxy"
  hostname    = "ha-proxy-${var.vpc_name}"
  zone        = var.subnet.ha-a.zone
  resources {
    cores         = var.vms_resources.ha-proxy.core
    memory        = var.vms_resources.ha-proxy.memory
    core_fraction = var.vms_resources.ha-proxy.fraction
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
    subnet_id = yandex_vpc_subnet.ha-a.id
    nat       = true
    ip_address = "192.168.40.10"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("./id_rsa.pub")}"
  }
}
