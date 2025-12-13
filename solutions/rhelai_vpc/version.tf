terraform {
  # require 1.9 or later to make use of cross-object referencing for input variable validations
  #   more info: https://www.hashicorp.com/blog/terraform-1-9-enhances-input-variable-validations
  required_version = ">= 1.9.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.86.1"
    }
  }
}
