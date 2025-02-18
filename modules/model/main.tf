locals {
  src_ansible_templates_dir  = "${path.module}/ansible-files"
  dst_files_dir              = "/root/terraform_files"
  dst_ansible_exe_shell_file = "${local.dst_files_dir}/ansible_exec.sh"
  dst_rhelai_inventory_file  = "${local.dst_files_dir}/rhelai-inventory.yaml"
  dst_ilab_playbook_file     = "${local.dst_files_dir}/ilab-playbook.yaml"
  dst_ilab_service_file      = "${local.dst_files_dir}/ilab-serve.service"
  dst_py_model_download_file = "${local.dst_files_dir}/get_model_files.py"
  ansible_executable_file    = "${local.src_ansible_templates_dir}/ansible_exec.sh.tftpl"
  ansible_inventory_file     = "${local.src_ansible_templates_dir}/rhelai-inventory.yaml"
  ansible_playbook_file      = "${local.src_ansible_templates_dir}/ilab-playbook.yaml"
  ansible_roles_ilab_file    = "${local.src_ansible_templates_dir}/roles/ilab/tasks/main.yaml"
  ansible_ilab_service_file  = "${local.src_ansible_templates_dir}/ilab-serve.service.tftpl"
  py_model_download_cos_file = "${local.src_ansible_templates_dir}/get_model_files.py.tftpl"
  model_dest_dir             = var.model_bucket_name != null ? "/root/.cache/instructlab/models/${var.model_bucket_name}" : "${local.dst_files_dir}/"

  l_model_repo             = var.model_repo != null ? var.model_repo : ""
  l_model_repo_token_value = var.model_repo_token_value != null ? var.model_repo_token_value : ""
  l_bucket_name            = var.model_bucket_name != null ? var.model_bucket_name : ""
  l_cos_region             = var.model_cos_region != null ? var.model_cos_region : ""
  l_crn_service_id         = var.model_bucket_crn != null ? var.model_bucket_crn : ""
}

##############################################################
# 1. Copy files to terraform directory
##############################################################

resource "terraform_data" "setup_ansible_host" {
  triggers_replace = [
    var.ssh_private_key,
    var.rhelai_ip,
    var.model_repo,
    var.model_repo_token_key,
    var.model_repo_token_value,
    var.model_bucket_name,
    var.model_cos_region,
    var.ibmcloud_api_key
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

  # Copy ilab-playbook file
  provisioner "file" {
    source      = local.ansible_playbook_file
    destination = local.dst_ilab_playbook_file
  }

  provisioner "file" {
    source      = local.ansible_inventory_file
    destination = local.dst_rhelai_inventory_file
  }

  # Create roles directory
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}/roles/ilab/tasks", ]
  }

  # Copy ilab-tasks file
  provisioner "file" {
    source      = local.ansible_roles_ilab_file
    destination = "${local.dst_files_dir}/roles/ilab/tasks/main.yaml"
  }

  # Copy ilab-service file
  provisioner "file" {
    content = templatefile(local.ansible_ilab_service_file, {
      model_name = try(length(var.model_bucket_name), 0) > 0 ? var.model_bucket_name : var.model_repo
    })
    destination = local.dst_ilab_service_file
  }

  # Copy ansible executable shell script file
  provisioner "file" {
    content = templatefile(local.ansible_executable_file, {
      rhelai_inventory_file  = local.dst_rhelai_inventory_file
      ilab_playbook_file     = local.dst_ilab_playbook_file
      ilab_service_file      = local.dst_ilab_service_file
      model_repository       = local.l_model_repo
      model_repo_token_key   = var.model_repo_token_key
      model_repo_token_value = local.l_model_repo_token_value
      bucket_name            = local.l_bucket_name
      region                 = local.l_cos_region
    })
    destination = local.dst_ansible_exe_shell_file
  }

  provisioner "file" {
    content = templatefile(local.py_model_download_cos_file, {
      ibmcloud_api_key = var.ibmcloud_api_key
      bucket_name      = local.l_bucket_name
      region           = local.l_cos_region
      dest_dir         = local.model_dest_dir
      crn_instance_id  = local.l_crn_service_id
    })
    destination = local.dst_py_model_download_file
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_ansible_exe_shell_file}"
    ]
  }
}

##############################################################
# 2. Execute ansible script remotely
##############################################################

resource "terraform_data" "execute_playbooks" {
  depends_on = [terraform_data.setup_ansible_host]

  triggers_replace = [
    var.ssh_private_key,
    var.rhelai_ip,
    var.model_repo,
    var.model_repo_token_key,
    var.model_repo_token_value,
    var.model_bucket_name,
    var.model_cos_region,
    var.ibmcloud_api_key
  ]

  connection {
    type        = "ssh"
    user        = "root"
    host        = var.rhelai_ip
    private_key = var.ssh_private_key
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      local.dst_ansible_exe_shell_file
    ]
  }
}

##############################################################
# 4. Clean up the files
##############################################################

resource "terraform_data" "clear_ansible_files" {
  triggers_replace = [
    var.ssh_private_key,
    var.rhelai_ip,
    var.model_repo,
    var.model_repo_token_key,
    var.model_repo_token_value,
    var.model_bucket_name,
    var.model_cos_region,
    var.ibmcloud_api_key,
    var.model_bucket_crn
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
