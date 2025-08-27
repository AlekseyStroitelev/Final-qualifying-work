output "node_ips" {
  value = {
    master_public   = yandex_compute_instance.master.network_interface[0].nat_ip_address
    master_private  = yandex_compute_instance.master.network_interface[0].ip_address
    worker1_public  = yandex_compute_instance.worker-1.network_interface[0].nat_ip_address
    worker1_private = yandex_compute_instance.worker-1.network_interface[0].ip_address
    worker2_public  = yandex_compute_instance.worker-2.network_interface[0].nat_ip_address
    worker2_private = yandex_compute_instance.worker-2.network_interface[0].ip_address
  }
}
