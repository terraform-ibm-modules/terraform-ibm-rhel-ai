locals {
  src_config_templates_dir    = "${path.module}/config"
  src_ansible_files_dir       = "${path.module}/ansible"
  https_proxy_config_file     = "${local.src_config_templates_dir}/https-proxy.conf"
  https_proxy_service_file    = "${local.src_config_templates_dir}/https-proxy.service"
  ansible_https_playbook      = "${local.src_ansible_files_dir}/https-playbook.yaml"
  ansible_inventory_file      = "${local.src_ansible_files_dir}/https-conf-inventory.yaml"
  ansible_https_tasks_file    = "${local.src_ansible_files_dir}/roles/proxy/tasks/main.yaml"
  dst_files_dir               = "/root/terraform_https_files"
  dst_https_proxy_conf        = "${local.dst_files_dir}/https-proxy.conf"
  dst_https_service_conf      = "${local.dst_files_dir}/https-proxy.service"
  dst_ansible_inventory       = "${local.dst_files_dir}/https-conf-inventory.yaml"
  dst_ansible_https_playbook  = "${local.dst_files_dir}/https-playbook.yaml"
  dst_ansible_https_task_file = "${local.dst_files_dir}/roles/proxy/tasks/main.yaml"
  dst_https_certificate       = "${local.dst_files_dir}/certificate.crt"
  dst_https_privatekey        = "${local.dst_files_dir}/private.key"

  l_https_certificate = var.https_certificate != null ? var.https_certificate : ""
  l_https_privatekey  = var.https_privatekey != null ? var.https_privatekey : ""
}

##############################################################
# 1. Copy files to terraform directory
##############################################################

resource "terraform_data" "setup_ansible_host" {

  triggers_replace = [
    var.ssh_private_key,
    var.https_certificate,
    var.https_privatekey,
    var.rhelai_ip
  ]

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.rhelai_ip
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  # Create terraform scripts directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  # Copy https proxy files
  provisioner "file" {
    source      = local.https_proxy_config_file
    destination = local.dst_https_proxy_conf
  }

  # Copy https service file
  provisioner "file" {
    source      = local.https_proxy_service_file
    destination = local.dst_https_service_conf
  }

  # Copy ansible inventory file
  provisioner "file" {
    source      = local.ansible_inventory_file
    destination = local.dst_ansible_inventory
  }

  # Copy ansible playbook file
  provisioner "file" {
    source      = local.ansible_https_playbook
    destination = local.dst_ansible_https_playbook
  }

  # Create roles directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}/roles/proxy/tasks", ]
  }

  # Copy ansible tasks file
  provisioner "file" {
    source      = local.ansible_https_tasks_file
    destination = local.dst_ansible_https_task_file
  }

  # Copy https certificate file
  provisioner "file" {
    content     = local.l_https_certificate
    destination = local.dst_https_certificate
  }

  # Copy https privatekey file
  provisioner "file" {
    content     = local.l_https_privatekey
    destination = local.dst_https_privatekey
  }
}

##############################################################
# 2. Run ansible to setup https or http
##############################################################

resource "terraform_data" "execute_playbooks" {
  triggers_replace = [
    var.ssh_private_key,
    var.https_certificate,
    var.https_privatekey,
    var.rhelai_ip
  ]
  depends_on = [terraform_data.setup_ansible_host]

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.rhelai_ip
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "ansible-playbook -i ${local.dst_ansible_inventory} ${local.dst_ansible_https_playbook}",
    ]
  }
}

##############################################################
# 4. Clean up the files
##############################################################

resource "terraform_data" "clear_ansible_files" {
  triggers_replace = [
    var.ssh_private_key,
    var.https_certificate,
    var.https_privatekey,
    var.rhelai_ip
  ]

  depends_on = [terraform_data.execute_playbooks]

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.rhelai_ip
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -fr ${local.dst_files_dir}"
    ]
  }
}
