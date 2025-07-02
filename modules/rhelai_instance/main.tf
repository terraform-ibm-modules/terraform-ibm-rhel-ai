#
# Developer tips:
#   - Below code should be replaced with the code for the root level module
#

locals {
  nvidia_types    = ["gx3-48x240x2l40s", "gx3-24x120x1l40s"]
  amd_types       = ["gx3d-208x1792x8mi300x"]
  intel_types     = ["gx3d-160x1792x8gaudi3"]
  l_rhel_ai_image = contains(local.nvidia_types, var.machine_type) ? "ibm-redhat-ai-nvidia-1-5-amd64-1" : contains(local.amd_types, var.machine_type) ? "ibm-redhat-ai-amd-1-5-amd64-1" : contains(local.intel_types, var.machine_type) ? "ibm-redhat-ai-intel-1-5-1-amd64-1" : "unknown"
}

data "ibm_is_image" "rhelai_image" {
  name = local.l_rhel_ai_image
}

##############################################################################
# Create new SSH key
##############################################################################

resource "ibm_is_ssh_key" "rhelai_ssh_key" {
  name           = "${var.prefix}-ssh-key"
  public_key     = var.ssh_key
  resource_group = var.resource_group_id
}

##############################################################################
# Create Custom Image
##############################################################################

resource "ibm_is_image" "custom_image" {
  for_each         = var.image_url != null && var.image_url != "" ? toset(["create"]) : toset([])
  name             = "${var.prefix}-custom-image"
  href             = var.image_url
  resource_group   = var.resource_group_id
  operating_system = "red-ai-9-amd64-nvidia-byol"

  # increase timeouts as per volume size
  timeouts {
    create = "40m"
  }
}

##############################################################################
# Create GPU instance
##############################################################################

resource "ibm_is_instance" "gpu_vsi_1" {
  name           = "${var.prefix}-vsi"
  resource_group = var.resource_group_id
  image          = var.image_url != null && var.image_url != "" ? ibm_is_image.custom_image["create"].id : data.ibm_is_image.rhelai_image.id
  profile        = var.machine_type
  vpc            = var.vpc_id
  zone           = var.zone
  keys           = [ibm_is_ssh_key.rhelai_ssh_key.id]
  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = [var.security_group_id]
  }
  boot_volume {
    size = 250
  }
  user_data = <<-EOT
    #!/bin/bash

    # Check if the script is run as root
    if [ "$EUID" -ne 0 ]; then
      echo "Please run as root."
      exit 1
    fi

    # Navigate to /etc directory
    if cd /etc; then
      echo "Changed directory to /etc."
    else
      echo "Failed to change directory to /etc. Exiting."
      exit 1
    fi

    # Create the 'ilab' directory if it doesn't already exist
    if [ ! -d "ilab" ]; then
      if mkdir ilab; then
        echo "Directory 'ilab' created."
      else
        echo "Failed to create directory 'ilab'. Exiting."
        exit 1
      fi
    else
      echo "Directory 'ilab' already exists."
    fi

    # Navigate to 'ilab' directory
    if cd ilab; then
      echo "Changed directory to 'ilab'."
    else
      echo "Failed to change directory to 'ilab'. Exiting."
      exit 1
    fi

    # Create or truncate the 'insights-opt-out' file
    if echo > insights-opt-out; then
      echo "File 'insights-opt-out' created or truncated."
    else
      echo "Failed to create or truncate 'insights-opt-out'. Exiting."
      exit 1
    fi

    # Verify the contents of /etc/ilab directory
    if ls -l /etc/ilab; then
      echo "Contents of /etc/ilab listed successfully."
    else
      echo "Failed to list contents of /etc/ilab. Exiting."
      exit 1
    fi

    pip install hf_transfer

    exit 0

  EOT

  timeouts {
    create = "60m"
    update = "60m"
  }
}
