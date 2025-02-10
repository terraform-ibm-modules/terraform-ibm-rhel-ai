########################################################################################################################
# ilab model serve variables
########################################################################################################################

variable "ssh_private_key" {
  description = "SSH Private Key to login"
  type        = string
  sensitive   = true
}

variable "rhelai_ip" {
  description = "Public IP address of RHEL.ai instance"
  type        = string
}

########################################################################################################################
# variables to get model from registry
########################################################################################################################

variable "model_repo" {
  description = "Provide the model path from hugging face registry only. If you have model in COS use the COS configuration variables"
  type        = string
}

variable "model_repo_token_key" {
  description = "The name / key of the variable to pass the authorization token of the model repository in hugging face"
  type        = string
}

variable "model_repo_token_value" {
  description = "The value of authorization token to access the model repository"
  type        = string
  sensitive   = true
}

########################################################################################################################
# variables to get model from cos bucket
########################################################################################################################


variable "bucket_name" {
  description = "Provide the COS bucket name where you model files reside. If you are using model registry then this field should be empty"
  type        = string
}

variable "cos_region" {
  description = "Provide COS region where the model bucket reside. If you are using model registry then this field should be empty"
  type        = string
}

variable "ibmcloud_api_key" {
  description = "Provide the ibmcloud api key to access model files."
  type        = string
  sensitive   = true
}

variable "crn_service_id" {
  description = "Provide Bucket instance CRN. If you are using model registry then this field should be empty"
  type        = string
}
