variable "compartment_ocid" {
  description = "Compartment name"
}

#variable "availability_domain" {
#  type = "list"
#}

variable "nsgs" {
  type = "list"
}

variable "AD" {
  type = "list"
}

variable "fault_domain" {
  type        = "list"
}

variable "compute_instance_count" {}
variable "compute_instance_shape" {}

variable "compute_hostname_prefix" {
  description = "Host name"
}

variable "compute_image" {
  description = "OS Image"
}

variable "compute_ssh_private_key" {
  description = "SSH key"
}

variable "compute_ssh_public_key" {
  description = "SSH key"
}

variable "bastion_ssh_private_key" {
  description = "SSH key"
}

variable "bastion_public_ip" {
  type = "string"
}

variable "bastion_user" {}

variable "compute_instance_user" {}

variable "compute_subnet" {
  type        = "list"
  description = "subnet"
}

variable "compute_bv_mount_path" {
  description = "Mount Path for the block volume"
}

/*variable "fss_instance_prefix" {}
variable "fss_subnet" {
  type = "list"
}
variable "export_path_fs1_mt1" {
  default = "/sieblelfs"
}
*/

variable "compute_assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address. "
  default     = true
}

variable "compute_boot_volume_size_in_gb" {}

variable "compute_block_volume_size_in_gb" {}

variable "timeout" {
  description = "Timeout setting for resource creation "
  default     = "10m"
}

variable timezone {}

variable user_data {}
