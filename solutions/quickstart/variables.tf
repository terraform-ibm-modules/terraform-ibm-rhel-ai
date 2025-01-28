########################################################################################################################
# Input Variables
########################################################################################################################

#
# Developer tips:
#   - Below are some common module input variables
#   - They should be updated for input variables applicable to the module being added
#   - Use variable validation when possible
#

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "rhelai-da"
}

variable "resource_group" {
  type        = string
  description = "The name of a new resource group to provision resources in."
}

variable "existing_resource_group" {
  type        = string
  description = "The name of a existing resource group to provision resources in. Do not set if you fill resource_group"
  default     = null
}

variable "region" {
  description = "The region where observability resources are created."
  type             = string  
}

variable "zone" {
  description = "The zone where the RHEL.ai instance needs to be deployed"
  type        = string
}

variable "ssh_key" {
  type        = string
  description = "A public ssh key is required to the private key that you have generated from. This is used for RHEL.ai VSI instance"
}

variable "image_url" {
  type        = string
  description = "A RHEL AI image url location downloaded and stored from REDHAT"
}

variable "sm_instance_id" {
  type        = string
  description = "Secrets Manager Instance ID"
}

variable  "sm_ssh_private_key_id" {
  type        = string
  description = "Secret ID of SSH Private Key stored in secret manager"
}

variable   "sm_cert_id" {
  type        = string
  description = "Secret ID of SSL certificate stored in secret manager"
}
