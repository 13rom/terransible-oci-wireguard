provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.oracle_api_key_fingerprint
  private_key_path = var.oracle_api_private_key_path
  region           = var.region
}

resource "oci_core_vcn" "wirehole_vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_ocid
  display_name   = "${var.display_name}-VCN"
  dns_label      = "${var.display_name}-VCN"
}

resource "oci_core_subnet" "wirehole_subnet" {
  availability_domain = var.free_tier_availability_domain
  cidr_block          = var.subnet_cidr_block
  display_name        = "${var.display_name}-Subnet"
  dns_label           = "${var.display_name}-Subnet"
  security_list_ids   = [oci_core_security_list.wirehole_security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.wirehole_vcn.id
  route_table_id      = oci_core_vcn.wirehole_vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.wirehole_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "wirehole_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.display_name}-IG"
  vcn_id         = oci_core_vcn.wirehole_vcn.id
}

resource "oci_core_default_route_table" "test_route_table" {
  manage_default_resource_id = oci_core_vcn.wirehole_vcn.default_route_table_id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.wirehole_internet_gateway.id
  }
}

resource "oci_core_security_list" "wirehole_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.wirehole_vcn.id
  display_name   = "${var.display_name}-SecurityList"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound ssh traffic from a all ports to port
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  // allow inbound udp traffic from all ports to 51820
  ingress_security_rules {
    protocol  = "17" // udp
    source    = "0.0.0.0/0"
    stateless = false

    udp_options {
      source_port_range {
        min = 1
        max = 65535
      }

      // These values correspond to the destination port range.
      min = var.wireguard_port
      max = var.wireguard_port
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    description = "icmp_inbound"
    protocol    = 1
    source      = "0.0.0.0/0"
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_instance" "wirehole_instance" {
  availability_domain = var.free_tier_availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.wirehole_subnet.id
    display_name     = "${var.instance_display_name}-VNIC"
    assign_public_ip = true
    hostname_label   = var.instance_display_name
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_instance_console_connection" "wirehole_instance_console_connection" {
  #Required
  instance_id = oci_core_instance.wirehole_instance.id
  public_key  = var.ssh_public_key
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.compartment_ocid
  ad_number      = var.availability_domain_number
}

# Gets a list of vNIC attachments on the instance
data "oci_core_vnic_attachments" "instance_vnics" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.free_tier_availability_domain
  instance_id         = oci_core_instance.wirehole_instance.id
}

# Gets the OCID of the first (default) vNIC
data "oci_core_vnic" "instance_vnic" {
  vnic_id = lookup(data.oci_core_vnic_attachments.instance_vnics.vnic_attachments[0], "vnic_id")
}

output "connect_with_ssh" {
  value = oci_core_instance_console_connection.wirehole_instance_console_connection.connection_string
}

output "connect_with_vnc" {
  value = oci_core_instance_console_connection.wirehole_instance_console_connection.vnc_connection_string
}
