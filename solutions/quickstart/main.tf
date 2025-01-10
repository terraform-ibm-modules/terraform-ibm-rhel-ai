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
# Create Workload VPC
##############################################################################

module "workload_vpc" {
  source              = "terraform-ibm-modules/landing-zone-vpc/ibm"
  name                = "workload"
  resource_group_id   = module.resource_group.resource_group_id
  region              = var.region  
  prefix              = var.prefix
  tags                = var.resource_tags
  network_acls        = [local.network-acl]
  use_public_gateways = {
    zone-1            = true
    zone-2            = false
    zone-3            = false
  }
  subnets             = {
    zone-1 = [
      {
        "acl_name" = "${var.prefix}-acl",
        "cidr" = "10.40.10.0/24",
        "name" = "gpu-vsi-subnet-1"        
      }
    ]
  }
}

##############################################################################
# Create GPU Based VSI Instance using RHEL.ai Custom Image Image
##############################################################################


module "gpu_vsi" {
  source                           = "terraform-ibm-modules/landing-zone-vsi/ibm"
  resource_group_id                = module.resource_group.resource_group_id
  prefix                           = var.prefix
  vpc_id                           = module.workload_vpc.vpc_id
  subnets                          = module.workload_vpc.subnet_zone_list
  image_id                         = ibm_is_image.custom_image.id
  machine_type                     = local.gpu_machine_type
  manage_reserved_ips              = false
  ssh_key_ids                      = [ ibm_is_ssh_key.rhelai_ssh_key.id ]
  vsi_per_subnet                   = 1
  create_security_group            = false
  user_data                        = null
}
