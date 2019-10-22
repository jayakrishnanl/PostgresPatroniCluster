# OCID of the VCN
vcn_id = ""
bastion_subnet = ""
pgsql_subnet = ""

# Compartment name
compartment_name = ""

# Timezone of compute instances
timezone = "GMT"

# SSH private key for instances
ssh_private_key_path = "/"

# Floating VIP
vip = ""

# Bastion instance shape
bastion_instance_shape = "VM.Standard2.1"

# pgsql instance shape
pgsql_instance_shape = "VM.Standard2.2"

# Size of volume (in gb) of the instances
compute_boot_volume_size_in_gb = "50"
compute_block_volume_size_in_gb = "250"

# OS user
bastion_user = "opc"
compute_instance_user = "opc"

# Hostname prefix to define hostname for pgsql nodes
pgsql_hostname_prefix = "pgsql"

# Number of pgsql nodes to be created
pgsql_instance_count = "3"

# Postgresql & ETCD Version - [Tested v3.3.15 for PgSQL 11 & v3.3.17 for PgSQL 12]
postgresql_version = "11"
etcd_version = "v3.3.15"

# Enable synchronous replication
synchronous_mode = "false"

# Postgres ports
pgsql_port = "5432"
pgbouncer_listen_port = "6432"










