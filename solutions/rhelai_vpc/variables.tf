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

variable "existing_resource_group" {
  type        = string
  description = "Select the name of a existing resource group or select NULL to create new resource group."
  default     = null
}

variable "region" {
  description = "The region where resources are created."
  type        = string
}

variable "zone" {
  description = "The zone where the RHEL AI instance needs to be deployed"
  type        = number
}

variable "subnet_id" {
  description = "An existing subnet id where the RHEL AI instance will be deployed. This is optional if you want to create RHEL AI instance in new subnet and VPC"
  type        = string
  default     = null
}

########################################################################################################################
# RHEL AI VSI instance input variables
########################################################################################################################


variable "image_url" {
  type        = string
  description = "A COS url location where RHEL AI image is downloaded and stored from Red Hat. This will create custom image"
  default     = null

  validation {
    condition     = var.image_url == null ? true : length(var.image_url) == 0 ? true : startswith(var.image_url, "cos://")
    error_message = "The image URL must be a COS URL with format `cos://<region>/<bucket>/<filename>`"
  }
}

variable "image_id" {
  type        = string
  description = "The RHEL AI image id to use while creating a GPU VSI instance. This is optional if you are creating custom image using the image_url"
  default     = null

  validation {
    condition     = var.image_id != null || var.image_url != null
    error_message = "You must supply either a image_id provided in cloud resources or image_url of RHEL AI image. Note - Image url should be a cos url where the image is stored."
  }
}

variable "machine_type" {
  type        = string
  description = "The machine type to be created. Please provide GPU based machine type to run the solution"
}

variable "ssh_key" {
  type        = string
  description = "A public ssh key is required to the private key that you have generated from. This is used for RHEL AI VSI instance"
}

variable "enable_private_only" {
  type        = bool
  description = "A flag to determine to have private IP only and no public network accessibility"
  default     = true
  nullable    = true
}

########################################################################################################################
# Install model variables
########################################################################################################################

variable "ssh_private_key" {
  description = "SSH Private Key to login and execute model service operations. Use the private key of SSH public key provided to the VSI instance"
  type        = string
  sensitive   = true
}

variable "model_repo_hugging_face" {
  type        = string
  description = "Provide the model path from hugging face registry only. If you have model is in COS use the COS configuration variables"
  default     = null
}

variable "model_repo_token_value" {
  description = "The value of authorization token to access the model repository from huggingface registry"
  type        = string
  sensitive   = true
  default     = null
}

variable "model_cos_bucket_name" {
  description = "Provide the COS bucket name where you model files reside. If you are using model registry then this field should be empty"
  type        = string
  default     = null

  validation {
    condition     = anytrue([(var.model_repo_hugging_face != null && var.model_cos_bucket_name == null), (var.model_cos_bucket_name != null && var.model_repo_hugging_face == null)])
    error_message = "You must supply either model_repo_hugging_face with model_repo_token_value for HF_TOKEN key (or) have model_cos_bucket_name, model_cos_region and model_cos_bucket_crn"
  }
}

variable "model_cos_region" {
  description = "Provide COS region where the model bucket reside. If you are using model registry then this field should be empty"
  type        = string
  default     = null

  validation {
    condition     = var.model_cos_bucket_name != null ? var.model_cos_region != null : true
    error_message = "You must supply model_cos_region when you provide model_cos_bucket_name and model_cos_bucket_crn"
  }
}

variable "model_cos_bucket_crn" {
  description = "Provide Bucket instance CRN. If you are using model registry then this field should be empty"
  type        = string
  default     = null

  validation {
    condition     = var.model_cos_bucket_name != null ? var.model_cos_bucket_crn != null : true
    error_message = "You must supply model_cos_bucket_crn when you provide model_cos_bucket_name, and model_cos_region"
  }
}

########################################################################################################################
# ilab config variables
########################################################################################################################

variable "enable_https" {
  description = "Enable https to model service?"
  type        = bool
  default     = false
  nullable    = false
}

variable "https_certificate" {
  description = "SSL certificate required for https setup. Required if enable_https is true"
  type        = string
  sensitive   = true
  default     = ""
}

variable "https_privatekey" {
  description = "SSL privatekey (optional) for https setup. Required if enable_https is true"
  type        = string
  sensitive   = true
  default     = ""
}

variable "model_apikey" {
  description = "Model API Key setup to authorize while inferencing the model"
  type        = string
  sensitive   = true
  default     = null
}
