resource "local_file" "inventory" {
  filename = "${var.path_to_inventory}/inventory.ini"
  content = templatefile("${path.module}/inventory.tpl", {
    master_public_ip   = yandex_compute_instance.master.network_interface[0].nat_ip_address
    master_private_ip  = yandex_compute_instance.master.network_interface[0].ip_address
    worker1_public_ip  = yandex_compute_instance.worker-1.network_interface[0].nat_ip_address
    worker1_private_ip = yandex_compute_instance.worker-1.network_interface[0].ip_address
    worker2_public_ip  = yandex_compute_instance.worker-2.network_interface[0].nat_ip_address
    worker2_private_ip = yandex_compute_instance.worker-2.network_interface[0].ip_address
  })
}
