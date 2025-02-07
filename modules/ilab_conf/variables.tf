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
  default     = "13.120.85.56"  
}

variable "enable_https" {
    description = "Enable https"
    type        = bool
    default     = true
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

variable "model_apikey" {
    description = "API Key to authorize while inferencing the model"
    type        = string
    sensitive   = true
    default     = null
}