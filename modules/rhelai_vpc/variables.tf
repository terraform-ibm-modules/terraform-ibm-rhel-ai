########################################################################################################################
# Input Variables
########################################################################################################################

#
# Developer tips:
#   - Below are some common module input variables
#   - They should be updated for input variables applicable to the module being added
#   - Use variable validation when possible
#

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
}

variable "resource_group_id" {
  type        = string
  description = "The if of a the resource group to provision resources in."
}

variable "zone" {
  description = "The zone where the RHEL.ai instance needs to be deployed"
  type        = string
}

variable "vpc_id" {
  description = "If there is existing VPC. Then provide the VPC id"
  type        = string
}
