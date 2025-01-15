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
# Create instance template
##############################################################################

resource "ibm_is_instance" "gpu_vsi" {
  name                                    = "${var.prefix}-instance"
  resource_group                          = module.resource_group.resource_group_id
  image                                   = ibm_is_image.custom_image.id
  profile                                 = local.gpu_machine_type    
  vpc                                     = ibm_is_vpc.rhelai_vpc.id
  zone                                    = var.zone
  keys                                    = [ibm_is_ssh_key.rhelai_ssh_key.id]
  primary_network_interface {
    subnet                                = ibm_is_subnet.rhelai_subnet.id
  }
  boot_volume {        
    size                                  = 250
  }
}

resource "ibm_is_subnet" "rhelai_subnet" {
  name                                      = "${var.prefix}-rhelai-subnet"
  resource_group                            = module.resource_group.resource_group_id
  vpc                                       = ibm_is_vpc.rhelai_vpc.id
  zone                                      = var.zone
  total_ipv4_address_count                  = 16
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
  target_id = ibm_is_instance.gpu_vsi_template.id
  weight    = 100
}