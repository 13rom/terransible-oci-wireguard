output "instance_id" {
  description = "ocid of created instances. "
  value       = oci_core_instance.wireguard_instance.id
}

output "private_ip" {
  description = "Private IPs of created instances. "
  value       = oci_core_instance.wireguard_instance.private_ip
}

output "public_ip" {
  description = "Public IPs of created instances. "
  value       = oci_core_instance.wireguard_instance.public_ip
}

locals {
  ansible-inventory = templatefile("templates/inventory.tmpl", {
    wireguard_ip      = oci_core_instance.wireguard_instance.public_ip,
    private_key       = var.ssh_private_key_path,
    wireguard_port    = var.wireguard_port,
    wireguard_ui_port = var.wireguard_ui_port
  })
}

locals {
  ssh-config = templatefile("templates/config.tmpl", {
    wireguard_ip = oci_core_instance.wireguard_instance.public_ip,
    private_key  = var.ssh_private_key_path
  })
}

locals {
  docker-compose-env = templatefile("templates/env.tmpl", {
    wireguard_ip      = oci_core_instance.wireguard_instance.public_ip,
    wireguard_port    = var.wireguard_port,
    wireguard_ui_port = var.wireguard_ui_port
  })
}

resource "local_file" "ansible_inventory" {
  content  = local.ansible-inventory
  filename = "../ansible/inventory/oci_inventory"
}

resource "local_file" "ssh_config" {
  content  = local.ssh-config
  filename = "../.ssh/config"
}

resource "local_file" "compose-env" {
  content  = local.docker-compose-env
  filename = "../ansible/files/.env"
}
