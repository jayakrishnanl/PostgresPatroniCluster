resource "oci_core_volume" "blockvolume" {
  count               = "${tonumber(var.compute_block_volume_size_in_gb) != 0 ? var.compute_instance_count : 0}"
  availability_domain = "${element(var.AD, count.index)}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.compute_hostname_prefix}vol${count.index + 1}"
  size_in_gbs         = "${tonumber(var.compute_block_volume_size_in_gb)}"
}

resource "oci_core_volume_attachment" "blockvolume_attach" {
  attachment_type = "paravirtualized"
  count           = "${tonumber(var.compute_block_volume_size_in_gb) != 0 ? var.compute_instance_count : 0}"
  instance_id     = "${element(oci_core_instance.compute.*.id, count.index)}"
  volume_id       = "${element(oci_core_volume.blockvolume.*.id, count.index)}"

  provisioner "remote-exec" {
    connection {
      agent               = false
      timeout             = "30m"
      host                = "${element(oci_core_instance.compute.*.private_ip, count.index)}"
      user                = "${var.compute_instance_user}"
      private_key         = "${var.compute_ssh_private_key}"
      bastion_host        = "${var.bastion_public_ip}"
      bastion_port        = "22"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${var.compute_ssh_private_key}"
    }

    inline = [
      "sudo -s bash -c 'pvcreate /dev/sdb'",
      "sudo -s bash -c 'vgcreate vgdata /dev/sdb'",
      "sudo -s bash -c 'lvcreate -l 100%VG -n lvdata vgdata'",
      "sudo -s bash -c 'mkfs.ext4 /dev/vgdata/lvdata'",
      "sudo -s bash -c 'mkdir -p ${var.compute_bv_mount_path}'",
      "sudo -s bash -c 'echo \"/dev/vgdata/lvdata ${var.compute_bv_mount_path} ext4 defaults,noatime,_netdev,nofail 0 2\" >> /etc/fstab'",
      "sudo -s bash -c 'mount -a'",
    ]
  }
}
