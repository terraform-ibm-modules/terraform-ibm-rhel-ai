########################################################################################################################
# ilab config variables
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

variable "enable_https" {
  description = "Enable https"
  type        = bool
}

variable "https_certificate" {
  description = "Https certificate"
  type        = string
  sensitive   = true
}

variable "https_privatekey" {
  description = "Https privatekey"
  type        = string
  sensitive   = true
}

variable "model_name" {
  description = "Model name"
  type        = string
  default     = ""
}

variable "model_apikey" {
  description = "API Key to authorize while inferencing the model"
  type        = string
  sensitive   = true
}
