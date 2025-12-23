##############################################################################
# Outputs
##############################################################################

output "rhelai_instance_id" {
  description = "The rhel.ai instance id that is provisioned."
  value       = ibm_is_instance.gpu_vsi_1.id
}

output "primary_network_interface_id" {
  description = "The primary network attached to RHEL.ai instance"
  value       = ibm_is_instance.gpu_vsi_1.primary_network_interface[0].id
}

output "primary_ip" {
  description = "The primary IP address of the VSI instance"
  value       = ibm_is_instance.gpu_vsi_1.primary_network_interface[0].primary_ip[0].address
}
