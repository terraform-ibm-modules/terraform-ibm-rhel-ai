########################################################################################################################
# RHEL.ai Model Serve Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to access IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "The region to provision the model."
  type             = string  
}

variable "sm_instance_id" {
  description      = "Secrets Manager instance ID that contain ssh private key and ssl certificates"
  type             = string  
}

variable "sm_ssh_private_key_id" {
  description      = "The id of the arbitrary secret that is created for storing ssh private key securely. Used for ssh to run commands in RHEL.ai instance"
  type             = string  
}

variable "sm_cert_id" {
  description      = "The secret id of ssl certificate stored in secrets manager. Used to create nginx (https) proxy service"
  type             = string  
}

variable "secrets_group_name" {
  description      = "The name of the secret group name where the ssh key and certificates are grouped. Please make sure to have both ssh key cert in one group if you ae using this field"
  type             = string
  default          = null
}

variable "public_ip_address" {
  description      = "The RHEL.ai instance public ip-address"
  type             = string  
}
