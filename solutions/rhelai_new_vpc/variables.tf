########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
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
  type        = string
}

variable "zone" {
  description = "The zone where the RHEL.ai instance needs to be deployed"
  type        = string
}

########################################################################################################################
# RHEL.ai VSI instance input variables
########################################################################################################################


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

variable "enable_private_only" {
  type        = bool
  description = "A flag to determine to have private IP only and no public network accessibility"
}

########################################################################################################################
# Install model variables
########################################################################################################################

variable "ssh_private_key" {
  description = "SSH Private Key to login"
  type        = string
  sensitive   = true
}

variable "model_repo" {
  type        = string
  description = "Provide the model path from hugging face registry only. If you have model in COS use the COS configuration variables"
}

variable "model_repo_token_key" {
  description = "The name / key of the variable to pass the authorization token of the model repository in hugging face"
  type        = string
  default     = "HF_TOKEN"
}

variable "model_repo_token_value" {
  description = "The value of authorization token to access the model repository"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Provide the COS bucket name where you model files reside. If you are using model registry then this field should be empty"
  type        = string
}

variable "cos_region" {
  description = "Provide COS region where the model bucket reside. If you are using model registry then this field should be empty"
  type        = string
}

variable "crn_service_id" {
  description = "Provide Bucket instance CRN. If you are using model registry then this field should be empty"
  type        = string
}

########################################################################################################################
# ilab config variables
########################################################################################################################

variable "enable_https" {
  description = "Enable https to model service?"
  type        = bool
}

variable "https_certificate" {
  description = "SSL certificate required for https setup"
  type        = string
  sensitive   = true
}

variable "https_privatekey" {
  description = "SSL privatekey (optional) for https setup"
  type        = string
  sensitive   = true
}

variable "model_apikey" {
  description = "Model API Key setup to authorize while inferencing the model"
  type        = string
  sensitive   = true
}
