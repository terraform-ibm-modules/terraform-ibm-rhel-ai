### Description

Create a DA to deploy RHEL AI VSI instance on IBM Cloud. The RHEL AI instance should serve a vLLM model using instruct lab. Users will be able to inference the model using a public end point or they can internally inference using the private endpoint.

A single solution inside the DA will use multiple modules to perform IaaC on IBM Cloud. The DA will provision a floating IP depending only on when the user requests a Public endpoint otherwise it will remove the floating IP once the RHEL AI model is served on the VSI instance.

The modules used are

- rhelai_vpc
- rhelai_instance
- model
- ilab_conf

### rhelai_vpc:

The RHEL AI VPC will create a VPC with a public gateway, subnets, and a security group with proper rules. The module has the following

- There is a conditional check on existing VPC provided with vpc_id in vars or a new VPC to be provisioned
- The security groups allow CIDR IP Ranges 161.26.0.0/16 and 166.8.0.0/14 for the DA terraform on IBM Cloud to serve models and configure the service using SSH on port 22
- The security group also allows port 8443 and 8000 on TCP to access the model served as a service
- The security group allows pings with ICMP to all the traffic

### rhelai_instance:

The RHEL AI Instance will provision a RHEL AI VSI instance with RHEL AI image. The module has the following

- A conditional check on image. If image id is provided then use to provision the image on VSI instance else create the image from COS bucket url
- user_data will initialize ilab inside the VSI instance

### model

A model is served using instruct lab on the VSI instance. The module has the following

- A conditional statement to check if a huggingface registry is provided or COS bucket parameters are provided to download the model on VSI instance
- A ansible script is used to serve the model with necessary configuration files
- The model is served using systemctl which inturn uses ilab serve
- The ansible checks for regex expression to ensure if the parameter provided is a registry download or COS download
- The model name to be served under instruct lab depends on registry path or  bucket name

### ilab_config

ilab configuration will update the ilab model service with user requested configurations like incorporating an apikey and provisioning http/s nginx server

- A conditional statement to check if the user requires http or https while deploying the nginx service
- A conditional check whether the model needs apikey when the model is served as a service
- An ansible script to update the ilab configuration and nginx service

All these modules are used in DA to deploy and serve the model as a service.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.76.3, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_https_conf"></a> [https\_conf](#module\_https\_conf) | ../../modules/https_conf | n/a |
| <a name="module_model"></a> [model](#module\_model) | ../../modules/model | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.2.0 |
| <a name="module_rhelai_instance"></a> [rhelai\_instance](#module\_rhelai\_instance) | ../../modules/rhelai_instance | n/a |
| <a name="module_rhelai_vpc"></a> [rhelai\_vpc](#module\_rhelai\_vpc) | ../../modules/rhelai_vpc | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_is_floating_ip.ip_address](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_floating_ip) | resource |
| [terraform_data.private_only](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [ibm_is_subnet.existing_subnet](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/is_subnet) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable https to model service? | `bool` | `false` | no |
| <a name="input_enable_private_only"></a> [enable\_private\_only](#input\_enable\_private\_only) | A flag to determine to have private IP only and no public network accessibility | `bool` | `true` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Select the name of a existing resource group or select NULL to create new resource group. | `string` | `null` | no |
| <a name="input_https_certificate"></a> [https\_certificate](#input\_https\_certificate) | SSL certificate required for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_https_privatekey"></a> [https\_privatekey](#input\_https\_privatekey) | SSL privatekey (optional) for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_hugging_face_access_token"></a> [hugging\_face\_access\_token](#input\_hugging\_face\_access\_token) | The value of authorization token to access the model repository from huggingface registry | `string` | `null` | no |
| <a name="input_hugging_face_model_name"></a> [hugging\_face\_model\_name](#input\_hugging\_face\_model\_name) | Provide the model path from hugging face registry only. If you have model is in COS use the COS configuration variables | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The RHEL AI image id to use while creating a GPU VSI instance. This is optional if you are creating custom image using the image\_url | `string` | `null` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | A COS url location where RHEL AI image is downloaded and stored from Red Hat. This will create custom image | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to be created. Please provide GPU based machine type to run the solution | `string` | n/a | yes |
| <a name="input_model_apikey"></a> [model\_apikey](#input\_model\_apikey) | Model API Key setup to authorize while inferencing the model | `string` | `null` | no |
| <a name="input_model_cos_bucket_crn"></a> [model\_cos\_bucket\_crn](#input\_model\_cos\_bucket\_crn) | Provide Bucket instance CRN. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_model_cos_bucket_name"></a> [model\_cos\_bucket\_name](#input\_model\_cos\_bucket\_name) | Provide the COS bucket name where you model files reside. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_model_cos_region"></a> [model\_cos\_region](#input\_model\_cos\_region) | Provide COS region where the model bucket reside. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all resources created by this example | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where resources are created. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public ssh key is required to the private key that you have generated from. This is used for RHEL AI VSI instance | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH Private Key to login and execute model service operations. Use the private key of SSH public key provided to the VSI instance | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | An existing subnet id where the RHEL AI instance will be deployed. This is optional if you want to create RHEL AI instance in new subnet and VPC | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone where the RHEL AI instance needs to be deployed | `number` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_image_id"></a> [custom\_image\_id](#output\_custom\_image\_id) | RHEL AI Custom Image ID created VPC image services |
| <a name="output_floating_ip"></a> [floating\_ip](#output\_floating\_ip) | The primary network attched to RHEL.ai instance |
| <a name="output_model_url"></a> [model\_url](#output\_model\_url) | The URL can be used to inference the models. For private only VSI instance you need to use the private IP |
| <a name="output_primary_network_interface_id"></a> [primary\_network\_interface\_id](#output\_primary\_network\_interface\_id) | The primary network attched to RHEL.ai instance |
| <a name="output_public_gateway_id"></a> [public\_gateway\_id](#output\_public\_gateway\_id) | Public gateway id attached to VPC |
| <a name="output_region"></a> [region](#output\_region) | The region all resources were provisioned in |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group created or used |
| <a name="output_rhelai_instance_id"></a> [rhelai\_instance\_id](#output\_rhelai\_instance\_id) | The rhel.ai instance id that is provisioned. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group id |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet ID where the RHEL.ai instance is located |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID where the RHEL.ai instance is located |
| <a name="output_zone"></a> [zone](#output\_zone) | The zone all resources were provisioned in |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
