# Find VCN CIDR
data "oci_core_vcn" "vcn_cidr" {
  vcn_id = "${var.vcn_id}"
}


# Get list of Availability Domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = "${var.tenancy_ocid}"
}

# Get list of Fault Domains
data "oci_identity_fault_domains" "fds" {
  availability_domain = "${element(local.ADs, 0)}"
  compartment_id      = "${var.compartment_ocid}"
}

# Get a list of VNIC attachments on the Compute instances
data "oci_core_vnic_attachments" "InstanceVnicAttachments" {
  count               = "${length(local.ADs)}"
  availability_domain = "${element(local.ADs, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
  instance_id         = "${element(module.create_pgsql.ComputeOcids, count.index)}"
}

locals {
  vnics = "${flatten(concat(data.oci_core_vnic_attachments.InstanceVnicAttachments.*.vnic_attachments))}"
}

# Get OCIDs of the Vnics
data "template_file" "vnic_ocids" {
  template = "$${name}"
  count    = "${var.pgsql_instance_count}"

  vars = {
    name = "${lookup(local.vnics[count.index], "vnic_id")}"
  }
}

/*
# Render inputs for HAProxy configuration file
data "template_file" "hapcfg" {
  count    = "${var.pgsql_instance_count}"
  template = "${file("${path.module}/userdata/haproxy.cfg.tpl")}"

  vars = {
    vip                   = "${var.vip}"
    ip0                   = "${element(module.create_pgsql.ComputePrivateIPs, count.index)}"
    ip1                   = "${element(module.create_pgsql.ComputePrivateIPs, count.index + 1)}"
    ip2                   = "${element(module.create_pgsql.ComputePrivateIPs, count.index + 2)}"
    pgsql_hostname_prefix = "${var.pgsql_hostname_prefix}"
    pgbouncer_listen_port = "${var.pgbouncer_listen_port}"
  }
}
*/

data "template_file" "kplcfg" {
  count    = "${var.pgsql_instance_count}"
  template = "${file("${path.module}/userdata/keepalived.cfg.tpl")}"

  vars = {
    ip0 = "${element(module.create_pgsql.ComputePrivateIPs, count.index)}"

    #ip1 = "${element(module.create_pgsql.ComputePrivateIPs, count.index + 1)}"
    #ip2 = "${element(module.create_pgsql.ComputePrivateIPs, count.index + 2)}"

    ip1 = "${chomp(replace(join("\n", module.create_pgsql.ComputePrivateIPs), "/${element(module.create_pgsql.ComputePrivateIPs, count.index)}/", ""))}"
  }
}

data "template_file" "failover" {
  count    = "${var.pgsql_instance_count}"
  template = "${file("${path.module}/userdata/ip_failover.sh.tpl")}"

  vars = {
    VNIC = "${element(data.template_file.vnic_ocids.*.rendered, count.index)}"
    VIP  = "${var.vip}"
  }
}

data "template_file" "iprelease" {
  count    = "${var.pgsql_instance_count}"
  template = "${file("${path.module}/userdata/ip_release.sh.tpl")}"

  vars = {
    VIP = "${var.vip}"
  }
}

/*
data "template_file" "inventory" {
  template = "${file("${path.module}/postgresql_cluster/inventory.tpl")}"

  vars = {
    ip0                   = "${element(module.create_pgsql.ComputePrivateIPs, 0)}"
    ip1                   = "${element(module.create_pgsql.ComputePrivateIPs, 1)}"
    ip2                   = "${element(module.create_pgsql.ComputePrivateIPs, 2)}"
    bastion_ip            = "${element(module.create_bastion.ComputePublicIPs, 0)}"
    pgsql_hostname_prefix = "${var.pgsql_hostname_prefix}"
    private_key_path      = "${var.private_key_path}"
  }
}

data "template_file" "main_yml" {
  template = "${file("${path.module}/postgresql_cluster/vars/main.yml.tpl")}"

  vars = {
    ip0                = "${element(module.create_pgsql.ComputePrivateIPs, 0)}"
    ip1                = "${element(module.create_pgsql.ComputePrivateIPs, 1)}"
    ip2                = "${element(module.create_pgsql.ComputePrivateIPs, 2)}"
    vip                = "${var.vip}"
    postgresql_version = "${var.postgresql_version}"
  }
}
*/
/*
data "template_file" "ansible_cfg" {
  template = "${file("${path.module}/postgresql_cluster/ansible.cfg.tpl")}"

  vars = {
    ssh_private_key_path = "${var.ssh_private_key_path}"
  }
}
*/

# Datasources for computing home region for IAM resources
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = "${var.tenancy_ocid}"
}

data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = ["${data.oci_identity_tenancy.tenancy.home_region_key}"]
  }
}

data "template_file" "bootstrap_bastion" {
  template = "${file("${path.module}/userdata/bootstrap_bastion.tpl")}"

  vars = {
    timezone = "${var.timezone}"
  }
}

data "template_file" "bootstrap_pgsql" {
  template = "${file("${path.module}/userdata/bootstrap_pgsql.tpl")}"

  vars = {
    timezone = "${var.timezone}"
  }
}
