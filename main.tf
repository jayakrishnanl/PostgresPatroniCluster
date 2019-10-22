locals {
  public_subnets  = "${list(var.bastion_subnet)}"
  private_subnets = "${list(var.pgsql_subnet)}"
  ADs             = "${data.oci_identity_availability_domains.ADs.availability_domains.*.name}"
  fds             = "${data.oci_identity_fault_domains.fds.fault_domains.*.name}"
}

# Create Bastion node
module "create_bastion" {
  source                          = "./modules/compute"
  compartment_ocid                = "${var.compartment_ocid}"
  AD                              = "${local.ADs}"
  fault_domain                    = "${local.fds}"
  compute_subnet                  = "${local.public_subnets}"
  compute_instance_count          = "1"
  compute_hostname_prefix         = "bastion-${substr(var.region, 3, 3)}"
  compute_boot_volume_size_in_gb  = "${var.compute_boot_volume_size_in_gb}"
  compute_block_volume_size_in_gb = "0"
  compute_bv_mount_path           = ""
  compute_assign_public_ip        = "true"
  compute_image                   = "${var.instance_image_ocid[var.region]}"
  compute_instance_user           = "${var.compute_instance_user}"
  compute_instance_shape          = "${var.bastion_instance_shape}"
  compute_ssh_public_key          = "${var.ssh_public_key}"
  compute_ssh_private_key         = "${var.ssh_private_key}"
  bastion_ssh_private_key         = "${var.ssh_private_key}"
  nsgs                            = "${list(oci_core_network_security_group.bastion_nsg.id)}"
  bastion_user                    = ""
  bastion_public_ip               = ""
  timezone                        = "${var.timezone}"
  user_data                       = "${data.template_file.bootstrap_bastion.rendered}"
}

module "create_pgsql" {
  source                          = "./modules/compute"
  compartment_ocid                = "${var.compartment_ocid}"
  AD                              = "${local.ADs}"
  fault_domain                    = "${local.fds}"
  compute_subnet                  = "${local.private_subnets}"
  compute_instance_count          = "${var.pgsql_instance_count}"
  compute_hostname_prefix         = "${var.pgsql_hostname_prefix}"
  compute_boot_volume_size_in_gb  = "${var.compute_boot_volume_size_in_gb}"
  compute_block_volume_size_in_gb = "${var.compute_block_volume_size_in_gb}"
  compute_bv_mount_path           = "/var/lib/pgsql/\"${var.postgresql_version}\"/data"
  compute_assign_public_ip        = "false"
  compute_image                   = "${var.instance_image_ocid[var.region]}"
  compute_instance_shape          = "${var.pgsql_instance_shape}"
  compute_instance_user           = "${var.compute_instance_user}"
  compute_ssh_public_key          = "${var.ssh_public_key}"
  compute_ssh_private_key         = "${var.ssh_private_key}"
  bastion_ssh_private_key         = "${var.ssh_private_key}"
  bastion_public_ip               = "${module.create_bastion.ComputePublicIPs.0}"
  nsgs                            = "${list(oci_core_network_security_group.pgsql_nsg.id)}"
  bastion_user                    = "${var.bastion_user}"
  timezone                        = "${var.timezone}"
  user_data                       = "${data.template_file.bootstrap_pgsql.rendered}"
}

module "iam_dynamic_group" {
  source = "./modules/iam/dynamic-group/"

  providers = {
    "oci" = "oci.home"
  }

  tenancy_ocid              = "${var.tenancy_ocid}"
  dynamic_group_name        = "keepalived_dynamic_group"
  dynamic_group_description = "dynamic group created for HaProxy env"
  dynamic_group_rule        = "instance.compartment.id = '${var.compartment_ocid}'"
  policy_compartment_id     = "${var.compartment_ocid}"
  policy_compartment_name   = "${var.compartment_name}"
  policy_name               = "keepalived-dynamic-policy"
  policy_description        = "dynamic policy created for HaProxy env"

  policy_statements = ["Allow dynamic-group keepalived_dynamic_group to manage public-ips in compartment ${var.compartment_name}", "Allow dynamic-group keepalived_dynamic_group to manage private-ips in compartment ${var.compartment_name}", "Allow dynamic-group keepalived_dynamic_group to use virtual-network-family in compartment ${var.compartment_name}"]
}

# Create NSGs
resource "oci_core_network_security_group" "bastion_nsg" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "BastionNSG"
}

resource "oci_core_network_security_group" "pgsql_nsg" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "PGsqlNSG"
}

resource "oci_core_network_security_group_security_rule" "bastion_nsg_rule_1" {
  network_security_group_id = "${oci_core_network_security_group.bastion_nsg.id}"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "bastion_nsg_rule_2" {
  network_security_group_id = "${oci_core_network_security_group.bastion_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_nsg_rule_3" {
  network_security_group_id = "${oci_core_network_security_group.bastion_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = "${oci_core_network_security_group.pgsql_nsg.id}"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "bastion_nsg_rule_4" {
  network_security_group_id = "${oci_core_network_security_group.bastion_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "bastion_nsg_rule_5" {
  network_security_group_id = "${oci_core_network_security_group.bastion_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

# Create NSG Rules
resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_1" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  direction                 = "EGRESS"
  protocol                  = "all"
  destination_type          = "CIDR_BLOCK"
  destination               = "0.0.0.0/0"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_2" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_3" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  description               = "Allow traffic from bastion NSG"
  protocol                  = "all"
  direction                 = "INGRESS"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = "${oci_core_network_security_group.bastion_nsg.id}"
  stateless                 = false
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_4" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "${var.pgsql_port}"
      max = "${var.pgsql_port}"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_5" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "2379"
      max = "2380"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_6" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "8008"
      max = "8008"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_7" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "5000"
      max = "5003"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_8" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "7000"
      max = "7000"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_9" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "6432"
      max = "6432"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_10" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "6"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = "5432"
      max = "5432"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_11" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  protocol                  = "112"
  direction                 = "INGRESS"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false
}
/*
resource "oci_core_network_security_group_security_rule" "pgsql_nsg_rule_12" {
  network_security_group_id = "${oci_core_network_security_group.pgsql_nsg.id}"
  direction                 = "INGRESS"
  protocol                  = "all"
  source_type               = "CIDR_BLOCK"
  source                    = "${data.oci_core_vcn.vcn_cidr.cidr_block}"
  stateless                 = false
}
*/
