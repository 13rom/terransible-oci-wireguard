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
    wireguard_ip = oci_core_instance.wireguard_instance.public_ip,
    private_key  = var.ssh_private_key_path
  })
}

resource "local_file" "sandbox_inventory" {
  content  = local.ansible-inventory
  filename = "../ansible/inventory/oci_inventory"
}

locals {
  ssh-config = templatefile("templates/config.tmpl", {
    wireguard_ip = oci_core_instance.wireguard_instance.public_ip,
    private_key  = var.ssh_private_key_path
  })
}

resource "local_file" "ssh_config" {
  content  = local.ssh-config
  filename = "../.ssh/config"
}
