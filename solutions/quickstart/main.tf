#
# Deployable Architecture
#   - Host RHEL.ai and Run grannite model as a service using ilab
#

##############################################################################
# Infrastructure setup to host rhel.ai on NVIDIA GPU 2l40 VSI instance
##############################################################################
module "rhelai" {
  source                   = "../../modules/rhelai"
  ibmcloud_api_key         = var.ibmcloud_api_key
  prefix                   = var.prefix
  resource_group           = var.resource_group
  existing_resource_group  = var.existing_resource_group
  region                   = var.region
  zone                     = var.zone
  ssh_key                  = var.ssh_key
  image_url                = var.image_url  
}

##############################################################################
# Wait until Infrastructure and VSI instance is completely initiated with ilab
##############################################################################
resource "time_sleep" "wait_for_gpu_vsi_ilab_init" {  
  depends_on      = [module.rhelai]
  create_duration = "3m"
}

##############################################################################
# ilab setup to run granite model as a service on RHEL.ai VSI instance
##############################################################################
module "ilab" {
  depends_on               = [time_sleep.wait_for_gpu_vsi_ilab_init]
  source                   = "../../modules/ilab"
  ibmcloud_api_key         = var.ibmcloud_api_key
  region                   = var.region
  sm_instance_id           = var.sm_instance_id
  sm_ssh_private_key_id    = var.sm_ssh_private_key_id
  sm_cert_id               = var.sm_cert_id
  public_ip_address        = module.rhelai.ip_address
}
