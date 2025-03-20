##############################################################################
# Outputs
##############################################################################

output "rhelai_instance_id" {
  description = "The rhel.ai instance id that is provisioned."
  value       = ibm_is_instance.gpu_vsi_1.id
}

output "primary_network_interface_id" {
  description = "The primary network attched to RHEL.ai instance"
  value       = ibm_is_instance.gpu_vsi_1.primary_network_interface[0].id
}

output "custom_image_id" {
  description = "RHEL AI Custom Image ID created VPC image services"
  value       = var.image_id != null && var.image_id != "" ? var.image_id : ibm_is_image.custom_image["create"].id
}
