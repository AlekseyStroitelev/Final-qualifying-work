# Запуск Ansible после создания inventory
resource "null_resource" "run_ansible" {
  depends_on = [local_file.inventory]

  provisioner "local-exec" {
    command = <<-EOT
      cd "${var.path_to_kubespray}" && ansible-playbook -i ./inventory/mycluster/inventory.ini --become --become-user=root cluster.yml
    EOT
  }

# Запуск при каждом изменении инвентори файла
  triggers = {
    inventory_change = local_file.inventory.content_sha256
  }
}
