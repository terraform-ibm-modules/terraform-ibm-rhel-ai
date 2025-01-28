##############################################################################
# Outputs
##############################################################################

output "resource_group_name" {
  description = "The name of the resource group used"
  value       = module.rhelai.resource_group_name
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
  value       = module.rhelai.image_id
}

output "url" {
  description = "The url to get Open API definitions for chatting with model"
  value       = module.ilab.model_url
}
