resource "oci_core_instance" "compute" {
  count               = "${var.compute_instance_count}"
  availability_domain = "${element(var.AD, count.index)}"
  display_name        = "${var.compute_hostname_prefix}-${count.index + 1}"
  fault_domain        = "${element(var.fault_domain, (count.index > length(var.fault_domain) - 1 ? count.index + 1 - length(var.fault_domain) : count.index))}"
  compartment_id      = "${var.compartment_ocid}"
  shape               = "${var.compute_instance_shape}"

  create_vnic_details {
    subnet_id        = "${element(var.compute_subnet, count.index)}"
    display_name     = "${var.compute_hostname_prefix}${count.index + 1}"
    assign_public_ip = "${var.compute_assign_public_ip}"
    hostname_label   = "${var.compute_hostname_prefix}${count.index + 1}"
    nsg_ids          = "${var.nsgs}"
  }

  source_details {
    source_type             = "image"
    source_id               = "${var.compute_image}"
    boot_volume_size_in_gbs = "${var.compute_boot_volume_size_in_gb}"
  }

  metadata = {
    ssh_authorized_keys = "${var.compute_ssh_public_key}"
    user_data           = "${base64encode(var.user_data)}"
  }

  timeouts {
    create = "${var.timeout}"
  }
}
