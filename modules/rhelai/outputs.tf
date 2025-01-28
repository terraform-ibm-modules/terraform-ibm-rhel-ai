##############################################################################
# Outputs
##############################################################################

output resource_group_id {
    description = "The ID of the resource group created or used"
    value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group used"
  value       = module.resource_group.resource_group_name
}

output "image_id" {
  description = "The rhel.ai custom image created on ibm cloud from the rehel.ai downloaded url"
  value       = ibm_is_image.custom_image.id
}

output "ip_address" {
  description = "The public ip address to connect to VSI instance"
  value       = ibm_is_floating_ip.ip_address.address
}
