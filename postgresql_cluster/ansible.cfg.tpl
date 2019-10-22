[defaults]
inventory = ./inventory
display_skipped_hosts = False
remote_tmp = /tmp/$${USER}/ansible
allow_world_readable_tmpfiles = false # or "true" if the temporary directory on the remote host is mounted with POSIX acls disabled or the remote machines use ZFS.
host_key_checking = False
timeout=60
private_key_file = ~/.ssh/opc

[persistent_connection]
retries = 3
connect_timeout = 60
command_timeout = 30

[ssh_connection]
ssh_args = -o ForwardAgent=yes -o StrictHostKeyChecking=no -o ControlMaster=auto -o ControlPersist=30m

# https://raw.githubusercontent.com/ansible/ansible/devel/examples/ansible.cfg
