output "ComputePrivateIPs" {
  #value = ["${oci_core_instance.compute.*.private_ip}"]
  value = "${oci_core_instance.compute.*.private_ip}"
}

output "ComputePublicIPs" {
  #value = ["${oci_core_instance.compute.*.public_ip}"]
  value = "${oci_core_instance.compute.*.public_ip}"
}

output "ComputeOcids" {
  #value = ["${oci_core_instance.compute.*.id}"]
  value = "${oci_core_instance.compute.*.id}"
}

/*
output "BvDeviceName" {
  value = ["${oci_core_volume_attachment.blockvolume_attach.*.device}"]
}
*/

