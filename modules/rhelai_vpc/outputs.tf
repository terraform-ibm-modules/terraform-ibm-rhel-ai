##############################################################################
# Outputs
##############################################################################

output "public_gateway" {
  description = "Public gateway instance"
  value       = ibm_is_public_gateway.rhelai_publicgateway
}

output "vpc_id" {
  description = "The VPC ID created"
  value       = ibm_is_vpc.rhelai_vpc.id
}

output "security_group_id" {
  description = "Security group id"
  value       = ibm_is_security_group.gpu_vsi_sg.id
}

output "subnet_id" {
  description = "Subnet id"
  value       = ibm_is_subnet.rhelai_subnet.id
}

output "public_gateway_id" {
  description = "Public gateway id attached to VPC"
  value       = ibm_is_public_gateway.rhelai_publicgateway.id
}
