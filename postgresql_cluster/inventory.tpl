# This is example inventory file!
# Please specify the ip addresses and connection settings for your environment
# The specified ip addresses will be used to listen by the cluster components.

# "postgresql_exists='true'" if PostgreSQL is already exists and runing
# "hostname=" variable is optional (used to change the server name)

[master]
${ip0} postgresql_exists='false' hostname=${pgsql_hostname_prefix}1

[replica]
%{ for addr in ip1 ~}
${addr} hostname=${pgsql_hostname_prefix}${index(ip1, addr) + 2}
%{ endfor ~}

[postgres_cluster:children]
master
replica


# Connection settings
[all:vars]
ansible_connection='ssh'
ansible_ssh_port='22'
ansible_user='opc'
#ansible_ssh_pass='testpas'  # "sshpass" package is required for use "ansible_ssh_pass"
ansible_ssh_private_key_file='~/.ssh/opc'
# ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q opc@${bastion_ip}"'
# ansible_python_interpreter='/usr/bin/python3'  # is required for use python3

