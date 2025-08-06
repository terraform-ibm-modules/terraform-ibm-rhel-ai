#
# Deployable Architecture
#   - Host RHEL.ai on new VPC
#
locals {
  always_run = timestamp()

  model_repo_token_key = "HF_TOKEN"
  l_user_zone          = var.zone != null ? "${var.region}-${var.zone}" : null
  l_zone               = var.subnet_id != null ? data.ibm_is_subnet.existing_subnet[0].zone : local.l_user_zone
  l_vpc                = var.subnet_id != null ? data.ibm_is_subnet.existing_subnet[0].vpc : null
  l_rg                 = var.existing_resource_group == null ? "${var.prefix}-rg" : null
  l_existing_rg        = var.existing_resource_group != null ? var.existing_resource_group : null
  l_num_gpus           = var.machine_type == "gx3-24x120x1l40s" ? "1" : "2"
  l_transport_protocol = var.enable_https ? "https" : "http"
  l_port               = var.enable_https ? "8443" : "8000"
}

data "ibm_is_subnet" "existing_subnet" {
  count      = var.subnet_id != null ? 1 : 0
  identifier = var.subnet_id
}


########################################################################################################################
# Resource Group
########################################################################################################################
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  resource_group_name          = local.l_rg
  existing_resource_group_name = local.l_existing_rg
}


##############################################################################
# VPC Infrastructure setup
##############################################################################

module "rhelai_vpc" {
  source            = "../../modules/rhelai_vpc"
  prefix            = var.prefix
  resource_group_id = module.resource_group.resource_group_id
  zone              = local.l_zone
  vpc_id            = local.l_vpc
  subnet_id         = var.subnet_id
}

##############################################################################
# RHEL.ai instance setup
##############################################################################

module "rhelai_instance" {
  source            = "../../modules/rhelai_instance"
  prefix            = var.prefix
  resource_group_id = module.resource_group.resource_group_id
  zone              = local.l_zone
  vpc_id            = module.rhelai_vpc.vpc_id
  subnet_id         = module.rhelai_vpc.subnet_id
  security_group_id = module.rhelai_vpc.security_group_id
  image_url         = var.image_url
  machine_type      = var.machine_type
  ssh_key           = var.ssh_key
  depends_on        = [module.rhelai_vpc]
}

##############################################################################
# Create floating ip address for the rhel.ai instance
##############################################################################

resource "ibm_is_floating_ip" "ip_address" {
  name           = "${var.prefix}-floating-ip"
  resource_group = module.resource_group.resource_group_id
  target         = module.rhelai_instance.primary_network_interface_id
  depends_on     = [module.rhelai_instance]
}

##############################################################################
# Install model and serve using ilab
##############################################################################

module "model" {
  source                 = "../../modules/model"
  ssh_private_key        = var.ssh_private_key
  rhelai_ip              = ibm_is_floating_ip.ip_address.address
  private_ip             = module.rhelai_instance.primary_ip
  model_repo             = var.hugging_face_model_name
  model_repo_token_key   = local.model_repo_token_key
  model_repo_token_value = var.hugging_face_access_token
  model_bucket_name      = var.model_cos_bucket_name
  model_cos_region       = var.model_cos_region
  ibmcloud_api_key       = var.ibmcloud_api_key
  model_bucket_crn       = var.model_cos_bucket_crn
  depends_on             = [ibm_is_floating_ip.ip_address]
  model_apikey           = var.model_apikey
  model_host             = var.enable_https ? "127.0.0.1" : "0.0.0.0"
  num_gpus               = local.l_num_gpus
}

##############################################################################
# Run https proxy using nginx
##############################################################################

module "https_conf" {
  count             = var.enable_https ? 1 : 0
  depends_on        = [module.model]
  source            = "../../modules/https_conf"
  ssh_private_key   = var.ssh_private_key
  rhelai_ip         = ibm_is_floating_ip.ip_address.address
  private_ip        = module.rhelai_instance.primary_ip
  https_certificate = var.https_certificate
  https_privatekey  = var.https_privatekey
}

##############################################################################
# Private or Public IP only
##############################################################################

resource "terraform_data" "private_only" {
  depends_on = [module.https_conf]
  triggers_replace = [
    local.always_run
  ]

  # Check if the service needs to be private only
  count = var.enable_private_only ? 1 : 0

  provisioner "local-exec" {
    command     = "./scripts/remove_float_ip.sh ${ibm_is_floating_ip.ip_address.id} ${var.region}"
    interpreter = ["bash", "-c"]
    environment = {
      IBMCLOUD_API_KEY = var.ibmcloud_api_key
    }
  }
}
