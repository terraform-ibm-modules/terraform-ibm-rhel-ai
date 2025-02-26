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
  description = "The id of the resource group to provision resources in."
}


variable "zone" {
  description = "The zone where the RHEL.ai instance needs to be deployed"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to create the RHEL.ai VSI instance"
}

variable "subnet_id" {
  type        = string
  description = "The Subnet ID where the RHEL.ai VSI instance will be created"
}

variable "security_group_id" {
  type        = string
  description = "The Security Group Id to attach to the RHEL.ai VSI instance"
}

variable "image_url" {
  type        = string
  description = "A RHEL AI image url location downloaded and stored from REDHAT"
}

variable "image_id" {
  type        = string
  description = "The RHEL.ai image id to use while creating a GPU VSI instance"
}

variable "machine_type" {
  type        = string
  description = "The machine type to be created. Please provide GPU based machine type to run the solution"
}

variable "ssh_key" {
  type        = string
  description = "A public ssh key is required to the private key that you have generated from. This is used for RHEL.ai VSI instance"
}
