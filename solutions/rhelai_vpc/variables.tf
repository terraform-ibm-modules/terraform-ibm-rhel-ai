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
  description = "Prefix to append to all resources created."
}

variable "existing_resource_group" {
  type        = string
  description = "Select the name of a existing resource group or select null to create new resource group."
  default     = null
}

variable "region" {
  description = "The region where resources are created."
  type        = string
}

variable "zone" {
  description = "The zone where the RHEL AI instance needs to be deployed."
  type        = number
}

variable "subnet_id" {
  description = "An existing subnet id where the RHEL AI instance will be deployed. This is optional and can be set to null if you want to create RHEL AI instance in a new subnet and VPC"
  type        = string
  default     = null
}

########################################################################################################################
# RHEL AI VSI instance input variables
########################################################################################################################


variable "image_url" {
  type        = string
  description = "A COS url location where RHEL AI image is downloaded from Red Hat and stored in COS. This will create custom image. The COS url should be of the format cos://{region}/{bucket}/{filename}. This is optional if you have existing custom image_id."
  default     = null

  validation {
    condition     = var.image_url == null ? true : length(var.image_url) == 0 ? true : startswith(var.image_url, "cos://")
    error_message = "The image URL must be a COS URL with format `cos://region/bucket/filename`"
  }
}

variable "machine_type" {
  type        = string
  description = "The machine type to be created. Please select one of the NVIDIA GPU based machine type to run the solution"
}

variable "ssh_key" {
  type        = string
  description = "A public ssh key is required that you have generated from. This is used for RHEL AI VSI instance"
}

variable "enable_private_only" {
  type        = bool
  description = "A flag to determine to have private IP only and no public network accessibility"
  default     = true
  nullable    = false
}

variable "install_required_binaries" {
  type        = bool
  default     = true
  description = "When true, run a script to ensure the required CLI binary (`jq`) is available in the runtime (for example Waypoint). If missing the script will attempt to download it to /tmp. Set to false to skip."
  nullable    = false
}

########################################################################################################################
# Install model variables
########################################################################################################################

variable "ssh_private_key" {
  description = "SSH Private Key that was generated to login and update model config and execute service operations. Use the private key of SSH public key provided in ssh_key."
  type        = string
  sensitive   = true
}

variable "hugging_face_model_name" {
  type        = string
  description = "Provide the model path from hugging face registry only. If you have model in COS use the COS configuration variables model_cos_bucket_name, model_cos_region and model_cos_bucket_crn"
  default     = null
}

variable "hugging_face_access_token" {
  description = "The value of hugging face user access token to access the model repository from huggingface registry. If you have model in COS, then this is optional. Use the COS configuration variables model_cos_bucket_name, model_cos_region and model_cos_bucket_crn"
  type        = string
  sensitive   = true
  default     = null
}

variable "model_cos_bucket_name" {
  description = "Provide the COS bucket name where you model files reside. If you are using hugging_face_model_name and hugging_face_access_token then this field is optional"
  type        = string
  default     = null

  validation {
    condition     = anytrue([(var.hugging_face_model_name != null && var.model_cos_bucket_name == null), (var.model_cos_bucket_name != null && var.hugging_face_model_name == null)])
    error_message = "You must supply either hugging_face_model_name with hugging_face_access_token for HF_TOKEN key (or) have model_cos_bucket_name, model_cos_region and model_cos_bucket_crn"
  }
}

variable "model_cos_region" {
  description = "Provide COS region where the model bucket reside. If you are using hugging_face_model_name and hugging_face_access_token then this field is optional"
  type        = string
  default     = null

  validation {
    condition     = var.model_cos_bucket_name != null ? var.model_cos_region != null : true
    error_message = "You must supply model_cos_region when you provide model_cos_bucket_name and model_cos_bucket_crn"
  }
}

variable "model_cos_bucket_crn" {
  description = "Provide Bucket instance CRN. If you are using hugging_face_model_name and hugging_face_access_token then this field is optional"
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
  description = "Enable https to your model service? If yes then a proxy nginx with https certificates will be created. https_cerificate and https_privatekey are required when true"
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
  description = "SSL privatekey for https setup. Required if enable_https is true"
  type        = string
  sensitive   = true
  default     = ""
}

variable "model_apikey" {
  description = "Model API Key to setup authorization while inferencing the model"
  type        = string
  sensitive   = true
  default     = null
}
