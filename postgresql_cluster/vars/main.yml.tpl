---
# Proxy variables (for offline installation)
proxy_env: {}
#  http_proxy: http://10.128.64.9:3128
#  https_proxy: http://10.128.64.9:3128

# -------------------------------------------

# Cluster variables
cluster_vip: "${vip}" # for client access to databases in the cluster
vip_interface: "ens3:1" # interface name (ex. "ens32")

patroni_cluster_name: "postgres-cluster"  # specify the cluster name
synchronous_mode: '${synchronous_mode}'  # or 'true' for enable synchronous database replication

patroni_superuser_username: "postgres"
# patroni_superuser_password: "postgres-pass" # please change password
patroni_superuser_password: "${patroni_superuser_password}"
patroni_replication_username: "replicator"
# patroni_replication_password: "replicator-pass" # please change password
patroni_replication_password: "${patroni_replication_password}" # please change password

patroni_install_version: "latest"  # or specific version (example 1.5.6)


# Load Balancing
with_haproxy_load_balancing: 'true' # or 'true' if you want to install and configure the load-balancing (based on haproxy+confd+keepalived)
haproxy_major: "1.8"  # if variable "with_haproxy_load_balancing=true"
haproxy_version: "1.8.20"  # version to build from source
keepalived_virtual_router_id: "133"  # specify a unique virtual_router_id

# vip-manager  (if with_haproxy_load_balancing: 'false')
vip_manager_version: "0.6" # version to install
vip_manager_config: "/etc/patroni/vip-manager.yml"
vip_manager_interval: "1000"  # time (in milliseconds) after which vip-manager wakes up and checks if it needs to register or release ip addresses.


# DCS (Distributed Consensus Store)
dcs_exists: 'false' # or 'true' if you do not want to install and configure the etcd cluster
dcs_type: "etcd"

 # if variable "dcs_exists=false" and "dcs_type=etcd":
etcd_ver: "v3.3.15" # version for deploy etcd cluster
etcd_data_dir: "/var/lib/etcd"
etcd_cluster_name: "etcdCluster" # ETCD_INITIAL_CLUSTER_TOKEN

 # if variable "dcs_exists=true" and "dcs_type=etcd" - specify ip-address your etcd cluster in the "patroni_etcd_hosts" variable
 # example (use existing cluster of 3 nodes)
patroni_etcd_hosts:
 %{ for addr in ip_addrs ~}
  - { host: ${addr}, port: "2379" }
 %{ endfor ~}

 # more options you can specify in the templates/patroni.yml.j2
 # documentation:
 # https://patroni.readthedocs.io/en/latest/SETTINGS.html#etcd
 # https://patroni.readthedocs.io/en/latest/SETTINGS.html#consul
 # https://patroni.readthedocs.io/en/latest/SETTINGS.html#zookeeper


# PostgreSQL variables
postgresql_version: "${postgresql_version}"
# postgresql_data_dir: see vars/Debian.yml or vars/RedHat.yml
postgresql_port: "5432"
postgresql_encoding: "UTF8"       # for bootstrap only (initdb)
postgresql_locale: "en_US.UTF-8"  # for bootstrap only (initdb)
postgresql_data_checksums: 'true' # for bootstrap only (initdb)

# (optional) list of users to be created (if not already exists)
postgresql_users: []
#  - { name: "mydb-user", password: "mydb-user-pass" }
#  - { name: "", password: "" }
#  - { name: "", password: "" }
#  - { name: "", password: "" }

# (optional) list of databases to be created (if not already exists)
postgresql_databases: []
#  - { db: "mydatabase", encoding: "UTF8", lc_collate: "ru_RU.UTF-8", lc_ctype: "ru_RU.UTF-8", owner: "mydb-user" }
#  - { db: "", encoding: "UTF8", lc_collate: "en_US.UTF-8", lc_ctype: "en_US.UTF-8", owner: "" }
#  - { db: "", encoding: "UTF8", lc_collate: "en_US.UTF-8", lc_ctype: "en_US.UTF-8", owner: "" }

# (optional) list of database extensions to be created (if not already exists)
postgresql_extensions: []
#  - { ext: "pg_stat_statements", db: "postgres"   }
#  - { ext: "pg_stat_statements", db: "mydatabase" }
#  - { ext: "pg_stat_statements", db: "" }
#  - { ext: "pg_stat_statements", db: "" }
#  - { ext: "pg_repack",          db: "" }  # postgresql-<version>-repack package is required
#  - { ext: "pg_stat_kcache",     db: "" }  # postgresql-<version>-pg-stat-kcache package is required
#  - { ext: "",     db: "" }
#  - { ext: "",     db: "" }
#  - { ext: "",     db: "" }

 # postgresql parameters to bootstrap dcs (are parameters for example)
postgresql_parameters:
  - { option: "max_connections",                     value: "100"     }
  - { option: "superuser_reserved_connections",      value: "5"       }
  - { option: "max_locks_per_transaction",           value: "64"      } # raise this value (ex. 512) if you have queries that touch many different tables (partitioning)
  - { option: "max_prepared_transactions",           value: "0"       }
  - { option: "huge_pages",                          value: "try"     } # or "on" if you set "vm_nr_hugepages" in kernel parameters
  - { option: "shared_buffers",                      value: "512MB"   } # please change this value
  - { option: "work_mem",                            value: "128MB"   } # please change this value
  - { option: "maintenance_work_mem",                value: "256MB"   } # please change this value
  - { option: "effective_cache_size",                value: "4GB"     } # please change this value
  - { option: "checkpoint_timeout",                  value: "15min"   }
  - { option: "checkpoint_completion_target",        value: "0.9"     }
  - { option: "min_wal_size",                        value: "2GB"     } # for PostgreSQL 9.5 and above (for 9.4 use "checkpoint_segments")
  - { option: "max_wal_size",                        value: "4GB"     } # for PostgreSQL 9.5 and above (for 9.4 use "checkpoint_segments")
  - { option: "wal_buffers",                         value: "32MB"    }
  - { option: "default_statistics_target",           value: "1000"    }
  - { option: "seq_page_cost",                       value: "1"       }
  - { option: "random_page_cost",                    value: "4"       } # "1.1" for SSD storage. Also, if your databases fits in shared_buffers
  - { option: "effective_io_concurrency",            value: "2"       } # "200" for SSD storage
  - { option: "synchronous_commit",                  value: "on"      } # or 'off' if you can you lose single transactions in case of a crash
  - { option: "autovacuum",                          value: "on"      } # never turn off the autovacuum!
  - { option: "autovacuum_max_workers",              value: "5"       }
  - { option: "autovacuum_vacuum_scale_factor",      value: "0.01"    }
  - { option: "autovacuum_analyze_scale_factor",     value: "0.02"    }
  - { option: "autovacuum_vacuum_cost_limit",        value: "200"     } # or 500/1000
  - { option: "autovacuum_vacuum_cost_delay",        value: "20"      }
  - { option: "autovacuum_naptime",                  value: "1s"      }
  - { option: "max_files_per_process",               value: "4096"    }
  - { option: "archive_mode",                        value: "on"      }
  - { option: "archive_timeout",                     value: "1800s"   }
  - { option: "archive_command",                     value: "cd ."    } # not doing anything yet with WAL-s
  - { option: "wal_level",                           value: "replica" } # "replica" for PostgreSQL 9.6 and above (for 9.4, 9.5 use "hot_standby")
  - { option: "wal_keep_segments",                   value: "130"     }
  - { option: "max_wal_senders",                     value: "10"      }
  - { option: "max_replication_slots",               value: "10"      }
  - { option: "hot_standby",                         value: "on"      }
  - { option: "wal_log_hints",                       value: "on"      }
  - { option: "shared_preload_libraries",            value: "pg_stat_statements,auto_explain" }
  - { option: "pg_stat_statements.max",              value: "10000"   }
  - { option: "pg_stat_statements.track",            value: "all"     }
  - { option: "pg_stat_statements.save",             value: "off"     }
  - { option: "auto_explain.log_min_duration",       value: "10s"     } # 10 sec (by default). Decrease this value if necessary
  - { option: "auto_explain.log_analyze",            value: "true"    }
  - { option: "auto_explain.log_buffers",            value: "true"    }
  - { option: "auto_explain.log_timing",             value: "false"   }
  - { option: "auto_explain.log_triggers",           value: "true"    }
  - { option: "auto_explain.log_verbose",            value: "true"    }
  - { option: "auto_explain.log_nested_statements",  value: "true"    }
  - { option: "track_io_timing",                     value: "on"      }
  - { option: "log_lock_waits",                      value: "on"      }
  - { option: "log_temp_files",                      value: "0"       }
  - { option: "track_activities",                    value: "on"      }
  - { option: "track_counts",                        value: "on"      }
  - { option: "track_functions",                     value: "all"     }
  - { option: "log_checkpoints",                     value: "on"      }
  - { option: "logging_collector",                   value: "on"      }
  - { option: "log_truncate_on_rotation",            value: "on"      }
  - { option: "log_rotation_age",                    value: "1d"      }
  - { option: "log_rotation_size",                   value: "0"       }
  - { option: "log_line_prefix",                     value: "'%t [%p-%l] %r %q%u@%d '" }
  - { option: "log_filename",                        value: "'postgresql-%a.log'"      }
  - { option: "log_directory",                       value: "{{ postgresql_log_dir }}" }
#  - { option: "idle_in_transaction_session_timeout", value: "600000"  } # for PostgreSQL 9.6 and above
#  - { option: "max_worker_processes",                value: "24"      }
#  - { option: "max_parallel_workers",                value: "12"      } # for PostgreSQL 10 and above
#  - { option: "max_parallel_workers_per_gather",     value: "4"       } # for PostgreSQL 9.6 and above
#  - { option: "max_parallel_maintenance_workers",    value: "2"       } # for PostgreSQL 11 and above
#  - { option: "hot_standby_feedback",                value: "on"      } # for "synchronous_mode"
#  - { option: "max_standby_streaming_delay",         value: "30s"     }
#  - { option: "wal_receiver_status_interval",        value: "10s"     }
#  - { option: "old_snapshot_threshold",              value: "60min"   } # for PostgreSQL 9.6 and above (1min-60d)
#  - { option: "",                                    value: ""        }
#  - { option: "",                                    value: ""        }


 # specify additional hosts that will be added to the pg_hba.conf
postgresql_pg_hba:
  - { type: "local", database: "all",       user: "postgres",  address: "",               method: "trust" } # "local=trust" required for ansible modules "postgresql_(user,db,ext)"
  - { type: "local", database: "all",       user: "all",       address: "",               method: "peer"  }
  - { type: "host",  database: "all",       user: "all",       address: "127.0.0.1/32",   method: "md5"   }
  - { type: "host",  database: "all",       user: "all",       address: "::1/128",        method: "md5"   }
#  - { type: "host", database: "mydatabase", user: "mydb-user", address: "192.168.0.0/24", method: "md5"   }


# PgBouncer parameters (more options in templates/pgbouncer.ini.j2)
install_pgbouncer: 'true'  # or 'false' if you do not want to install and configure the pgbouncer service
pgbouncer_conf_dir: "/etc/pgbouncer"
pgbouncer_log_dir: "/var/log/pgbouncer"
pgbouncer_listen_port: 6432
max_client_conn: 10000
max_db_connections: 1000

pgbouncer_pools:
  - { name: "postgres", dbname: "postgres", pool_parameters: "" }
#  - { name: "mydatabase", dbname: "mydatabase", pool_parameters: "pool_size=20 pool_mode=transaction" }
#  - { name: "", dbname: "", pool_parameters: "" }
#  - { name: "", dbname: "", pool_parameters: "" }

pgbouncer_users:
  - { username: "{{ patroni_superuser_username }}", password: "{{ patroni_superuser_password }}" }
#  - { username: "mydb-user", password: "mydb-user-pass" }
#  - { username: "", password: "" }
#  - { username: "", password: "" }
#  - { username: "", password: "" }


# System variables
ntp_enabled: 'false' # specify 'true' if you want to install and configure the ntp service
ntp_servers: []
#  - "10.128.64.44"
#  - "10.128.64.45"

timezone: []
#timezone: "Europe/Dublin"

locales:
  - { language_country: "en_US", encoding: "UTF-8" }
  - { language_country: "ru_RU", encoding: "UTF-8" }
#  - { language_country: "", encoding: "" }


# Kernel parameters
 # these parameters for example! Specify kernel options for your system
sysctl_conf:
  - { name: "vm.swappiness",                  value: "1"         }
  - { name: "vm.min_free_kbytes",             value: "102400"    }
  - { name: "vm.dirty_expire_centisecs",      value: "1000"      }
  - { name: "vm.dirty_background_bytes",      value: "67108864"  }
  - { name: "vm.dirty_bytes",                 value: "536870912" }
#  - { name: "vm.nr_hugepages",                value: "9510"      } # example "9510"=18GB
  - { name: "vm.zone_reclaim_mode",           value: "0"         }
  - { name: "kernel.numa_balancing",          value: "0"         }
  - { name: "kernel.sched_migration_cost_ns", value: "5000000"   }
  - { name: "kernel.sched_autogroup_enabled", value: "0"         }
  - { name: "net.ipv4.ip_nonlocal_bind",      value: "1"         }
  - { name: "net.ipv4.ip_forward",            value: "1"         }
  - { name: "net.ipv4.ip_local_port_range",   value: "1024 65535" }
  - { name: "net.netfilter.nf_conntrack_max", value: "1048576"    }
#  - { name: "",            value: "" }
#  - { name: "",            value: "" }


# Transparent Huge Pages
disable_thp: 'true' # or 'false'


# Max open file limit
set_limits: 'true' # or 'false'
limits_user: "postgres"
soft_nofile: 65536
hard_nofile: 200000


# I/O Scheduler
set_scheduler: 'false' # or 'true'
scheduler:
  - { sched: "deadline" , nr_requests: "1024", device: "sda" }
#  - { sched: "noop" , nr_requests: "1024", device: "sdb" }
#  - { sched: "" , nr_requests: "1024", device: "" }

# Non-multiqueue I/O schedulers:
  # cfq         - for desktop systems and slow SATA drives
  # deadline    - for SAS drives (recommended for databases)
  # noop        - for SSD drives
# Multiqueue I/O schedulers (blk-mq):
## (Recommend the use of blk-mq in environments that support it. For Fast SSD Storage and Linux kernel 4.12+)
  # mq-deadline - (recommended for databases)
  # none        - (ideal for fast random I/O devices such as NVMe)
  # bfq         - (avoid for databases)
  # kyber


# SSH Keys
enable_SSH_Key_based_authentication: 'true' # or 'false'
ssh_key_user: "opc"
ssh_key_state: "present"
ssh_known_hosts: "{{ groups['postgres_cluster'] }}"


# Firewall (ansible-role-firewall)
 # https://github.com/geerlingguy/ansible-role-firewall
firewall_enabled_at_boot: true

firewall_allowed_tcp_ports:
  - "{{ ansible_ssh_port }}"
  - "{{ postgresql_port }}"
  - "{{ pgbouncer_listen_port }}"
  - "2379" # ETCD port
  - "2380" # ETCD port
  - "8008" # Patroni REST API port
  - "5000" # HAProxy (read/write) master
  - "5001" # HAProxy (read only) all replicas
  - "5002" # HAProxy (read only) synchronous replica only
  - "5003" # HAProxy (read only) asynchronous replicas only
  - "7000" # HAProxy stats

firewall_additional_rules:
  - "iptables -p vrrp -A INPUT -j ACCEPT"  # Keepalived (vrrp)
  - "iptables -p vrrp -A OUTPUT -j ACCEPT" # Keepalived (vrrp)

 # disable firewalld (installed by default on RHEL/CentOS) or ufw (installed by default on Ubuntu)
firewall_disable_firewalld: false
firewall_disable_ufw: true

