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

output "region" {
  description = "The region all resources were provisioned in"
  value       = var.region
}

output "prefix" {
  description = "The prefix used to name all provisioned resources"
  value       = var.prefix
}

output "image_id" {
  description = "The rhel.ai custom image created on ibm cloud from the rehel.ai downloaded url"
  value       = ibm_is_image.custom_image.id
}
