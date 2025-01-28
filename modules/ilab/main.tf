#
# Developer tips:
#   - Below code should be replaced with the code for the root level module
#

##############################################################################
# Data - SSH Private Key
##############################################################################

data "ibm_sm_arbitrary_secret" "sshkey" {
  instance_id   = "${var.sm_instance_id}"
  region        = "${var.region}"
  secret_id     = "${var.sm_ssh_private_key_id}"
}

##############################################################################
# Write the SSH key to a temporary file
# Make the file only readable by the owner
##############################################################################

resource "local_file" "ssh_key" {
  content  = <<EOT
${data.ibm_sm_arbitrary_secret.sshkey.payload}

EOT
  filename = "${path.module}/temp_private_key"
}

resource "null_resource" "set_permissions" {
  provisioner "local-exec" {
    command = "chmod 600 ${local_file.ssh_key.filename}"
  }
  depends_on = [local_file.ssh_key]
}

##############################################################################
# Run the Ansible playbook
##############################################################################

resource "null_resource" "run_ansible_host" {
  #Execute the ansible command form local system
  provisioner "local-exec" {
    command = <<EOT
ansible-playbook -i ${var.public_ip_address}, --private-key ${local_file.ssh_key.filename} --extra-vars "secret_manager_instance_id=\"${var.sm_instance_id}\" secret_ssl_cert_id=\"${var.sm_cert_id}\" region=\"${var.region}\" ansible_ssh_common_args=\"-o StrictHostKeyChecking=no\"" ${path.module}/rhelai-playbook.yaml
EOT

    environment = {
      IBMCLOUD_APIKEY = var.ibmcloud_api_key
    }
  }
  depends_on = [null_resource.set_permissions]
}

##############################################################################
# Clean up temporary files created 
# when terraform is destroyed abruptly
# or completed successfully
##############################################################################

resource "null_resource" "cleanup_destroy" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -fr ${path.module}/temp_private_key"    
  }

  # Explicitly link to the resource to ensure cleanup runs after creation
  triggers = {
    file_created = local_file.ssh_key.filename
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {    
    command = "rm -fr ${path.module}/temp_private_key"    
  }  

  depends_on = [null_resource.run_ansible_host]
}
