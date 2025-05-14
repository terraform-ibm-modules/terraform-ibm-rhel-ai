########################################################################################################################
# https config variables
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

variable "private_ip" {
  description = "Private IP address of RHEL.ai instance"
  type        = string
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
