##############################################################################
# Outputs
##############################################################################

output "resource_group_id" {
  description = "The ID of the resource group created or used"
  value       = module.resource_group.resource_group_id
}

output "region" {
  description = "The region all resources were provisioned in"
  value       = var.region
}

output "zone" {
  description = "The zone all resources were provisioned in"
  value       = local.l_zone
}


output "vpc_id" {
  description = "VPC ID where the RHEL.ai instance is located"
  value       = module.rhelai_vpc.vpc_id
}


output "subnet_id" {
  description = "Subnet ID where the RHEL.ai instance is located"
  value       = module.rhelai_vpc.subnet_id
}

output "public_gateway_id" {
  description = "Public gateway id attached to VPC"
  value       = module.rhelai_vpc.public_gateway_id
}

output "security_group_id" {
  description = "Security group id"
  value       = module.rhelai_vpc.security_group_id
}

output "rhelai_instance_id" {
  description = "The rhel.ai instance id that is provisioned."
  value       = module.rhelai_instance.rhelai_instance_id
}

output "primary_network_interface_id" {
  description = "The primary network attched to RHEL.ai instance"
  value       = module.rhelai_instance.primary_network_interface_id
}

output "floating_ip" {
  description = "The primary network attched to RHEL.ai instance"
  value       = var.enable_private_only ? "" : ibm_is_floating_ip.ip_address.address
}

output "model_url" {
  description = "The URL can be used to inference the models. For private only VSI instance you need to use the private IP"
  value       = var.enable_private_only ? "${local.l_transport_protocol}://${module.rhelai_instance.primary_ip}:${local.l_port}/docs" : "${local.l_transport_protocol}://${ibm_is_floating_ip.ip_address.address}:${local.l_port}/docs"
}
