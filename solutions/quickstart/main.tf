#
# Developer tips:
#   - Below code should be replaced with the code for the root level module
#

##############################################################################
# Locals
##############################################################################

locals {

  gpu_machine_type = "gx3-48x240x2l40s"

  network-acl = {
    name = "${var.prefix}-acl"
    add_ibm_cloud_internal_rules = false
    add_vpc_connectivity_rules   = false
    prepend_ibm_rules            = false
    rules = [ {
        name                     = "${var.prefix}-inbound"
        action                   = "allow"
        source                   = "0.0.0.0/0"
        destination              = "0.0.0.0/0"
        direction                = "inbound"
      },
      {
        name                     = "${var.prefix}-outbound"
        action                   = "allow"
        source                   = "0.0.0.0/0"
        destination              = "0.0.0.0/0"
        direction                = "outbound"
      } 
    ]
  }
}

########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.resource_group  
  existing_resource_group_name = var.existing_resource_group
}

##############################################################################
# Create new SSH key
##############################################################################

resource "ibm_is_ssh_key" "rhelai_ssh_key" {
  name              = "${var.prefix}-ssh-key"
  public_key        = var.ssh_key
  resource_group    = module.resource_group.resource_group_id
}

##############################################################################
# Create Custom Image
##############################################################################

resource "ibm_is_image" "custom_image" {
  name              = "rhel-ai-custom-image-da"
  href              = var.image_url
  resource_group    = module.resource_group.resource_group_id
  operating_system  = "red-ai-9-amd64-nvidia-byol"

  //increase timeouts as per volume size
  timeouts {
    create = "40m"
  }
}


##############################################################################
# Create VPC and Subet
##############################################################################

resource "ibm_is_vpc" "rhelai_vpc" {
  name                    = "${var.prefix}-rhelai-vpc"
  resource_group          = module.resource_group.resource_group_id
}

resource "ibm_is_public_gateway" "rhelai_publicgateway" {
  name                                      = "${var.prefix}-rhelai-gateway"
  resource_group                            = module.resource_group.resource_group_id
  vpc                                       = ibm_is_vpc.rhelai_vpc.id
  zone                                      = var.zone
}

resource "ibm_is_subnet" "rhelai_subnet" {
  name                                      = "${var.prefix}-rhelai-subnet"
  resource_group                            = module.resource_group.resource_group_id
  vpc                                       = ibm_is_vpc.rhelai_vpc.id
  zone                                      = var.zone
  public_gateway                            = ibm_is_public_gateway.rhelai_publicgateway.id
  total_ipv4_address_count                  = 16
}

##############################################################################
# Create Security Group
##############################################################################


resource "ibm_is_security_group" "gpu_vsi_sg" {
  name                                      = "${var.prefix}-sg"
  resource_group                            = module.resource_group.resource_group_id
  vpc                                       = ibm_is_vpc.rhelai_vpc.id
}

resource "ibm_is_security_group_rule" "rule1" {
  group                                     = ibm_is_security_group.gpu_vsi_sg.id  
  direction                                 = "inbound"
  icmp {
  }  
  depends_on = [ibm_is_security_group.gpu_vsi_sg]
}

resource "ibm_is_security_group_rule" "rule2" {
  group                                     = ibm_is_security_group.gpu_vsi_sg.id
  direction                                 = "inbound"
  tcp {
    port_min                                = 22
    port_max                                = 22
  }
  depends_on = [ibm_is_security_group_rule.rule1]
}

##############################################################################
# Create GPU instance
##############################################################################

resource "ibm_is_instance" "gpu_vsi" {
  name                                    = "${var.prefix}-gpu-vsi"
  resource_group                          = module.resource_group.resource_group_id
  image                                   = ibm_is_image.custom_image.id
  profile                                 = local.gpu_machine_type    
  vpc                                     = ibm_is_vpc.rhelai_vpc.id
  zone                                    = var.zone
  keys                                    = [ibm_is_ssh_key.rhelai_ssh_key.id]
  primary_network_interface {
    subnet                                = ibm_is_subnet.rhelai_subnet.id
    security_groups                       = [ibm_is_security_group.gpu_vsi_sg.id]
  }
  boot_volume {        
    size                                  = 250
  }
  user_data                               = <<-EOT
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

    # Navigate to 'root' directory
    if cd /root; then
      echo "Changed directory to /root."
    else
      echo "Failed to change directory to /root. Exiting."
      exit 1
    fi

    # Check if 'ilab' command exists and runs
    if command -v ilab &> /dev/null; then
      echo "'ilab' command exists. Running 'ilab'."
      if ilab; then
        echo "'ilab' command ran successfully."
      else
        echo "'ilab' command failed to run."
        exit 1
      fi
    else
      echo "'ilab' command not found. Please ensure it is installed and in your PATH."
      exit 1
    fi


    # Run 'ilab config init' and select the default option (0)
    echo "0" | ilab config init

    if [ $? -eq 0 ]; then
      echo "'ilab config init' completed successfully with default CPU-only profile."
    else
      echo "Failed to initialize 'ilab' configuration. Exiting."
      exit 1
    fi



    exit 0

  EOT
  
  timeouts {
    create = "120m"
    update = "120m"
  }
}

##############################################################################
# Create load balancer
##############################################################################

resource "ibm_is_lb" "lb_app" {
  name                                      = "${var.prefix}-lb"
  resource_group                            = module.resource_group.resource_group_id
  subnets                                   = [ ibm_is_subnet.rhelai_subnet.id ]
  type                                      = "public"
}

resource "ibm_is_lb_pool" "lb_pool" {
  name           = "${var.prefix}-lb-pool"
  lb             = ibm_is_lb.lb_app.id
  algorithm      = "round_robin"
  protocol       = "http"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "http"
  proxy_protocol = "v1"
}

resource "ibm_is_lb_pool_member" "lb_pool_member" {
  lb        = ibm_is_lb.lb_app.id
  pool      = ibm_is_lb_pool.lb_pool.pool_id
  port      = 8000
  target_id = ibm_is_instance.gpu_vsi.id
  weight    = 100
}
