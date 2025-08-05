output "master_external_ip" {
    value = data.yandex_compute_instance.master.network_interface.0.nat_ip_address
}

output "worker-1_external_ip" {
    value = data.yandex_compute_instance.worker-1.network_interface.0.nat_ip_address
}

output "worker-2_external_ip" {
    value = data.yandex_compute_instance.worker-2.network_interface.0.nat_ip_address
}
