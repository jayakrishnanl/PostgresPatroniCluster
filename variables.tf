variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "region" {
  default = "eu-frankfurt-1"
}

variable "compartment_ocid" {}
variable "compartment_name" {}

variable "vcn_id" {
  description = "OCID your VCN - Make sure you have tagged the Private & Public Subnets per instructions"
}

variable "bastion_subnet" {
  description = "OCID of Bastion Subnet - Regional"
  default     = ""
}

variable "pgsql_subnet" {
  description = "OCID of Pgsql Subnet - Regional"
  default     = ""
}

# Compute Instance variables
variable "ssh_public_key" {
  description = "SSH public key for instances"
}

variable "ssh_private_key" {
  description = "SSH private key for instances"
}

variable "ssh_private_key_path" {
  description = "SSH private key path for instances"
}

variable "compute_boot_volume_size_in_gb" {
  description = "Boot volume size for the nodes"
}

variable "compute_block_volume_size_in_gb" {
  description = "Block volume size in gb"
}

variable "pgsql_instance_count" {
  description = "Number of pgsql nodes"
}

variable "pgsql_hostname_prefix" {
  description = "Hostname profix for pgsql Nodes"
}

variable "pgsql_instance_shape" {
  description = "pgsql Instance shape"
}

variable "bastion_instance_shape" {
  description = "Bastion node shape"
}

variable "bastion_user" {
  description = "Bastion OS user"
}

variable "compute_instance_user" {
  description = "Compute node OS user"
}

variable "instance_image_ocid" {
  type = "map"

  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.7-2019.09.25-0"
    ap-mumbai-1    = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaefcax7pqzhgcpiaxomtzvwj67cssuxhazggbhoxjv4adcvsfkfga"
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaxabo4p5asejscj4ba4weg62owtivojokmtcjyr6eqrdeq4dgfzvq"
    ap-sydney-1    = "ocid1.image.oc1.ap-sydney-1.aaaaaaaahggevnzn2hs3abhwacvv5jxnguoxdej3bnuy5t4cy3jrslubgqoa"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaatbwoj3ee5sbaa6u5ptpy74bukkqmj75bptvn7dpezovpdvr6ds2q"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaanljihk7bncal55wmgk5yrt23kpongv733zx5w5k4h46qs4srgqua"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajqghpxnszpnghz3um66jywaw5q3pudfw5qwwkyu24ef7lcsyjhsq"
    eu-zurich-1    = "ocid1.image.oc1.eu-zurich-1.aaaaaaaakla6mguktwqu7hmv75p7haiharf4usbpvjeogl7pnk3tbyqmawbq"
    sa-saopaulo-1  = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaaj6eqq3vky7mwktyewgylrvn7dhaqno6ypd6lt3yj7qigrfe7a4ca"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaaf4nj5yoqo7gv6ht6t7gtcr5de5slhy52alv3nqyjvmmh25knbama"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa3onyerinivkpiqektrd3idoeo72fuz56cpz6rihkvqulmoux5qkq"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaalza4xew5okvv42djc3bphidkf7pa7xy435uieguz4aau735flbmq"
  }
}

variable "timezone" {
  description = "Set timezone for servers"
}

variable "vip" {
  description = "LB Floating IP - Please use an unused IP from your Subnet"
}

variable "postgresql_version" {
  description = "Postgresql Version to be installed"
  default     = "v3.3.15"
}

variable "etcd_version" {
  description = "Etcd Version to be installed [Tested v3.3.15 for PgSQL 11 & v3.3.17 for PgSQL 12]"
  default     = "v3.3.15"
}

variable "pgsql_port" {
  description = "pgsql Port"
  default     = "5432"
}

variable "pgbouncer_listen_port" {
  description = "PGBouncer port"
  default     = "6432"
}

variable "synchronous_mode" {
  description = "Enable synchronous replication"
  default     = "false"
}

# Postgres/Patroni passwords
variable "patroni_superuser_password" {
  description = "Enter password for patroni super user - 'postgres'"
  #default     = "postgres-pass"
}

variable "patroni_replication_password" {
  description = "Enter password for patroni replication user - 'replicator'"
  #default     = "replicator-pass"
}


