resource "null_resource" "provision_Keepalived" {
  count = "${var.pgsql_instance_count}"

  connection {
    agent               = false
    timeout             = "30m"
    host                = "${element(module.create_pgsql.ComputePrivateIPs, count.index)}"
    user                = "${var.compute_instance_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.create_bastion.ComputePublicIPs[0]}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
      "sudo yum -y install keepalived",
      # "sudo yum -y install haproxy",
      "sudo firewall-offline-cmd  --zone=public --add-port=80/tcp",
      "sudo firewall-offline-cmd  --zone=public --add-port=443/tcp",
      "sudo /bin/systemctl restart firewalld",
      "sudo firewall-cmd --add-rich-rule='rule protocol value=\"vrrp\" accept' --permanent",
      "sudo firewall-cmd --add-port={5432,6432,5000,5001,5002,5003,7000,8008,2379,2380}/tcp --permanent",
      "sudo firewall-cmd --reload",
      #"sudo mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig",
      "sudo mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.orig",
    ]
  }
}

resource "null_resource" "provision_config_files" {
  depends_on = ["null_resource.provision_Keepalived"]
  count      = "${var.pgsql_instance_count}"

  connection {
    agent               = false
    timeout             = "30m"
    host                = "${element(module.create_pgsql.ComputePrivateIPs, count.index)}"
    user                = "${var.compute_instance_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.create_bastion.ComputePublicIPs[0]}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${var.ssh_private_key}"
  }

  /*
  provisioner "file" {
    content     = "${element(data.template_file.hapcfg.*.rendered, count.index)}"
    destination = "/tmp/haproxy.cfg"
  }
  */

  provisioner "file" {
    content     = "${element(data.template_file.kplcfg.*.rendered, count.index)}"
    destination = "/tmp/keepalived.conf"
  }

  provisioner "file" {
    content     = "${element(data.template_file.iprelease.*.rendered, count.index)}"
    destination = "/tmp/ip_release.sh"
  }

  provisioner "file" {
    content     = "${element(data.template_file.failover.*.rendered, count.index)}"
    destination = "/tmp/ip_failover.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
      # "sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg",
      "sudo cp /tmp/keepalived.conf /etc/keepalived/keepalived.conf",
      "sudo cp /tmp/ip_failover.sh /usr/libexec/keepalived/ip_failover.sh",
      "sudo cp /tmp/ip_release.sh /usr/libexec/keepalived/ip_release.sh",
      "sudo chmod +x /usr/libexec/keepalived/ip_failover.sh",
      "sudo chmod +x /usr/libexec/keepalived/ip_release.sh",
      #"sudo systemctl enable haproxy",
      #"sudo systemctl start haproxy",
      "sudo systemctl enable keepalived",
      "sudo systemctl start keepalived",
    ]
  }
}

resource "null_resource" "configure_ansible" {
  depends_on = ["null_resource.provision_config_files"]

  connection {
    agent               = false
    timeout             = "30m"
    host                = "${element(module.create_pgsql.ComputePrivateIPs, 2)}"
    user                = "${var.compute_instance_user}"
    private_key         = "${var.ssh_private_key}"
    bastion_host        = "${module.create_bastion.ComputePublicIPs[0]}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${var.ssh_private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y python-oci-cli",
    ]
  }

  /*
  provisioner "local-exec" {
    command = "cat > ./postgresql_cluster/inventory <<EOL\n${data.template_file.inventory.rendered}\nEOL"
  }

  provisioner "local-exec" {
    command = "cat > ./postgresql_cluster/vars/main.yml <<EOL\n${data.template_file.main_yml.rendered}\nEOL"
  }
  */

  provisioner "local-exec" {
    command = "cat > ./postgresql_cluster/inventory <<EOL\n${templatefile("${path.module}/postgresql_cluster/inventory.tpl", { ip0 = module.create_pgsql.ComputePrivateIPs[0], ip1 = "${compact(split(",", chomp(replace(join(", ", module.create_pgsql.ComputePrivateIPs), module.create_pgsql.ComputePrivateIPs[0], ""))))}", bastion_ip = "${element(module.create_bastion.ComputePublicIPs, 0)}", pgsql_hostname_prefix = "${var.pgsql_hostname_prefix}", private_key_path = "${var.private_key_path}" })}\nEOL"
  }

  provisioner "local-exec" {
    command = "cat > ./postgresql_cluster/vars/main.yml <<EOL\n${templatefile("${path.module}/postgresql_cluster/vars/main.yml.tpl", { vip = "${var.vip}", ip_addrs = "${module.create_pgsql.ComputePrivateIPs}", postgresql_version = "${var.postgresql_version}", synchronous_mode = "${var.synchronous_mode}", patroni_replication_password = "${var.patroni_replication_password}", patroni_superuser_password = "${var.patroni_superuser_password}" })}\nEOL"
  }
}

resource "null_resource" "run_ansible" {
  depends_on = ["null_resource.configure_ansible"]

  connection {
    agent       = false
    timeout     = "30m"
    host        = "${module.create_bastion.ComputePublicIPs[0]}"
    user        = "${var.bastion_user}"
    private_key = "${var.ssh_private_key}"
  }

  provisioner "file" {
    source      = "./postgresql_cluster"
    destination = "~/"
  }

  provisioner "file" {
    content     = "${var.ssh_private_key}"
    destination = "~/.ssh/opc"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/opc",
      "chown ${var.bastion_user}:${var.bastion_user} ~/.ssh/opc",
      "sleep 180",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ~/postgresql_cluster/deploy_pgcluster.yml -i ~/postgresql_cluster/inventory",
    ]
  }
}

