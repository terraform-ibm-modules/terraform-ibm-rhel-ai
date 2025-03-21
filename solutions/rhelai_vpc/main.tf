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
  version                      = "1.1.6"
  resource_group_name          = var.resource_group
  existing_resource_group_name = var.existing_resource_group
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
  image_id          = var.image_id
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
  model_repo             = var.model_repo_hugging_face
  model_repo_token_key   = local.model_repo_token_key
  model_repo_token_value = var.model_repo_token_value
  model_bucket_name      = var.model_cos_bucket_name
  model_cos_region       = var.model_cos_region
  ibmcloud_api_key       = var.ibmcloud_api_key
  model_bucket_crn       = var.model_cos_bucket_crn
  depends_on             = [ibm_is_floating_ip.ip_address]
}

##############################################################################
# Install model and serve using ilab
##############################################################################

module "ilab_conf" {
  depends_on        = [module.model]
  source            = "../../modules/ilab_conf"
  ssh_private_key   = var.ssh_private_key
  rhelai_ip         = ibm_is_floating_ip.ip_address.address
  enable_https      = var.enable_https
  https_certificate = var.https_certificate
  https_privatekey  = var.https_privatekey
  model_name        = module.model.model_name
  model_apikey      = var.model_apikey
}

##############################################################################
# Private or Public IP only
##############################################################################

resource "terraform_data" "private_only" {
  depends_on = [module.ilab_conf]
  triggers_replace = [
    local.always_run
  ]

  # Check if the service needs to be private only
  count = var.enable_private_only ? 1 : 0

  provisioner "local-exec" {
    command = "terraform destroy -target=ibm_is_floating_ip.ip_address -auto-approve -lock=false"
  }
}
