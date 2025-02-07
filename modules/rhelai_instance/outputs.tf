##############################################################################
# Outputs
##############################################################################

output "rhelai_instance_id" {
  description = "The rhel.ai instance id that is provisioned."
  value       = ibm_is_instance.gpu_vsi_1.id
}

output "primary_network_interface_id" {
  description = ""
  value       = ibm_is_instance.gpu_vsi_1.primary_network_interface[0].id
}
