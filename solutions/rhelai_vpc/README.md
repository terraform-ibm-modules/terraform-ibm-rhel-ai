## Overview

The DA provides RHEL AI instance on IBM Cloud and serves a fine-tuned model as a service with a public end point or a private endpoint. The RHEL AI instance serves a vLLM model using instruct lab.

The "Quick Start" solution  inside the DA have modules to perform IaaC and run Ansible scripts on IBM Cloud. The DA provisions a floating IP to RHEL AI VSI Instance depending if only the user requests a public endpoint otherwise keeps only the private end point.

The modules used are -

- rhelai_vpc
- rhelai_instance
- model
- https_conf

### rhelai_vpc:

The RHEL AI VPC will create a VPC with a public gateway, subnets, and a security group with proper rules. The module has the following

- VPC and Subnet are created only when user does not provide any existing subnet for to deploy VSI instance
- The security groups allow IBM Cloud Schematic CIDR IP Ranges for the DA terraform on IBM Cloud to download, configure  and serve models using SSH on port 22
- The security group also allows port 8443 and 8000 on TCP to access the model service endpoint
- The security group allows pings with ICMP to all the traffic
- Public gateway allows VSI instance to download models from hugging face registry

### rhelai_instance:

The RHEL AI Instance will provision a NVIDIA GPU based VSI instance with RHEL AI image. The module has the following

- Creates a custom image on VPC from COS bucket that has RHEL AI image or use a custom image already created in the VPC region
- user_data will initialize ilab inside the VSI instance

### model

Download and serve the model in the RHEL AI VSI instance that was provisioned in rhelai_instance module. The module has the following

- Download the model from huggingface registry or from COS bucket
- A ansible script is used to serve the model with necessary configuration files
- The model name to be served under instruct lab depends on registry path or bucket name
- API Key to authorize the requests while inferencing the model

### https_config

 Provisioning https nginx server with signed / unsigned certificate

- Enable https by deploying the nginx service

All these modules are used in DA to deploy and serve the model as a service using instruct lab.

## Planning

Before you begin the deployment of RHEL AI instance on IBM Cloud, make sure that you understand and meet the prerequisites.

### Confirm your IBM Cloud settings

Complete the following steps before you deploy the RHEL AI deployable architecture.

#### Confirm or set up an IBM Cloud account:

Make sure that you have an IBM Cloud Pay-As-You-Go or Subscription account:

- If you don't have an IBM Cloud account, [create one](https://cloud.ibm.com/docs/account?topic=account-account-getting-started).
- If you have a Trial or Lite account, [upgrade your account](https://cloud.ibm.com/docs/account?topic=account-upgrading-account).

### Set the IAM permissions

1. Set up account access (Cloud Identity and Access Management (IAM)):

    a. Create an IBM Cloud [API key](https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui#create_user_key). The user who owns this key must have the Administrator role.

    b. [Set up access groups](https://cloud.ibm.com/docs/account?topic=account-account-getting-started#account-gs-accessgroups).

    User access to IBM Cloud resources is controlled by using the access policies that are assigned to access groups.

    When you assign access to the group

    - Select All Identity and Access enabled services .

    - Select Resource Group

    - Select VPC Infrastructure Services

    - Select Cloud Object Storage

2. Verify access roles

    IAM access roles are required to install this deployable architecture and create all the required elements.

    You need the following permissions for this deployable architecture:

    - Access to view API Keys in All Identity and Access enabled services

    - Create resource group or access existing resource group

    - Create and modify IBM Cloud VPC services, virtual server instances, networks, network prefixes, storage volumes, SSH keys, and security groups of this VPC.

    - Access existing Object Storage services.

### Access for IBM Cloud projects

You can use IBM Cloud projects as a deployment option. Projects are designed with infrastructure as code and compliance in mind to help ensure that your projects are managed, secure, and always compliant. For more information, see [Learn about IaC deployments with projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

You need the following access to create a project and create project tooling resources within the account. Make sure you have the following access:

- The Editor role on the Projects service.
- The Editor and Manager role on the Schematics service
- The Viewer role on the resource group for the project

For more information, see [Assigning users access to projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-access-project).

### Create an SSH key

Make sure that you have an SSH key that you can use for authentication. This key is used to log in to RHEL AI virtual server instance that you create.

Your SSH key must be an RSA or ED25519 key type with a key size of either 2048 bits or 4096 bits.

If your Mac system generates a key size of 3072 bits (by default), run one of the following commands to make sure that the generated key is a supported size.

For RSA SSH key type, issue:

`ssh-keygen -t rsa -b 2048 -C "user_ID"`

For ED25519 SSH key type, issue:

`ssh-keygen -t ed25519 -b 2048 -C "user_ID"`

### Download RHEL AI and upload to IBM COS bucket

To provision a RHEL AI instance you require the latest IBM Cloud NVIDIA based RHEL AI image in IBM Cloud COS bucket. Download [RHEL AI for NVIDIA on IBM Cloud](https://developers.redhat.com/products/rhel-ai/download) image from Red Hat.


*Note: You may need to create [Red Hat account](https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/auth?response_type=code&client_id=rhd-dm&redirect_uri=https%3A%2F%2Fdevelopers.redhat.com%2Fcontent-gateway%2Frest%2Fkeycloak&state=edaacce8-f115-473d-b87a-ba0cec4f197f&login=true&scope=openid+rhdsupportable) to download RHEL AI image.*

After you download the RHEL AI QCOW image, you need to upload in to the COS bucket. You can find the instructions to create a IBM Cloud COS instance and bucket in [Object Storage docs](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-secure-content-store)

*Note: Uploading the large QCOW image directly into Cloud Object Storage might take too long and also may fail. Use IBM Aspera for large file transfers to your Cloud Object Storage bucket. You can also use [minio client](https://min.io/docs/minio/linux/reference/minio-mc.html) cli tool for fast uploads to COS*


### Create Hugging Face registry access token

You may need Hugging Face user access toke when you download models from the Hugging Face registry. On how to create Hugging Face user access token follow the instructions provided in [User access tokens](https://huggingface.co/docs/hub/en/security-tokens)

### SSL Certificates for HTTPS

If you choose to enable https protocol while accessing the model service running on RHEL AI then you need to have SSL certificates. You can have self signed ssl certificates for dev but for production you need to get a signed certificate with a private key.

To create self signed certificate, follow the instructions from  [Using OpenSSL to generate and format certificates](https://www.ibm.com/docs/en/api-connect/10.0.x_cd?topic=profile-using-openssl-generate-format-certificates). Make sure to save the certificate file and private key file.

## Deploying RHEL AI on IBM Cloud with a model

You can deploy a deployable architecture from the IBM Cloud catalog. You can choose one of several deployment options, including with IBM Cloud projects. [Learn about IaC deployments with projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

### Deploying with IBM Cloud projects

To deploy a RHEL AI deployable architecture through the IBM Cloud catalog, follow these steps:

1. Make sure that you comply with the prerequisites in the [planning](#planning) topic:

- Have an IBM Cloud API key.
- Verify access roles.
- Create an SSH key.
- Download RHEL AI
- Create Hugging Face registry access token
- SSL Certificates for HTTPS (Optional)


2. Go to the IBM Cloud [catalog](https://cloud.ibm.com/catalog#reference_architecture) and search for `RHEL AI on IBM Cloud with model inferencing`

3. Click the tile for the deployable architecture to open the details.

4. Select the latest product version in the Architecture section.

5. Click "Add to project" button.

6. Create a new project by providing Name, Configuration Name, Region and Resource Group

7. Click Create button after filling the required fields

8. Provide the IBM Cloud API key created in the planning section under [Set the IAM permissions](#set-the-iam-permissions)

9. Click on the Required fields tab and fill in the fields. Click on `i` icon for more details about the fields. You can also find the complete set of fields and their description below under [Inputs](#inputs)

10. Click on the Optional fields tab and fill in the necessary fields. The fields are optional based on selection of one over the other. Those fields are

    a. RHEL AI Image - provide image_url to COS (or) provide image_id if you manually created a RHEL AI custom image in the VPC. The image_url of COS should be of the format

    `cos://<region>/<bucket-name>/<image-object-name>`

    eg: `cos://us-east/rhel-ai-images/rhel-ai-nvidia-1.4-1739107849-x86_64-kvm.qcow2`

    b. Download the model from Hugging Face registry or from COS bucket. You need to give one or the other. For Hugging face registry use the model name and the access token

    example of model name: `ibm-granite/granite-3.2-8b-instruct`

    c. If you select enable_https to true then you need to give the fields https_certificate and https_privatekey

You can find the complete set of fields under [Inputs](#inputs)

11. After you enter the fields, click Save button to save the project configurations of the Deployable Architecture

12. After you save, click Validate to validate the generated plan. Once the validation is successful you can review the cost breakdown of resources that gets deployed. If the validation is unsuccessful then click on the Validation Failed to see the logs. If there are any empty fields (you may need to revet them back to null) or other issues in your configuration click Edit button to go back to configuration to edit the required and optional fields and save and validate again until its successful. If you still have issue contact the support team.

13. After validating and verifying the cost estimate, you can approve by providing the comments and clicking the button Approve

14. Once you are ready, you can click Deploy button to provision the resources. You can click view logs to see what resources are getting provisioned. If for some reason deployment fails you can verify the logs and report the errors to support team.

15. Once the deployment is successful, you can check the output of the deployment by clicking on "Changes deployed successfully". You see the summary of resources deployed

16. Click on View Resources button to see resources that got deployed and active

17. Change the tab to Outputs to view model details and the RHEL AI VSI details. You see a model_url in the outputs when you selected enable_private field as false (if enable_private is true then the model_url is empty in outputs). Click on the model_url to see the API documentation to inference the model

18. To undeploy the resources click on the "more options" (:) menu on the top right corner beside Edit button and you see undeploy option. Click the undeploy button to destroy all the resources including the resource group.


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
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable https to model service? If yes then a proxy nginx with https certificates will be created. https\_cerificate and https\_privatekey are required when true | `bool` | `false` | no |
| <a name="input_enable_private_only"></a> [enable\_private\_only](#input\_enable\_private\_only) | A flag to determine to have private IP only and no public network accessibility | `bool` | `true` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Select the name of a existing resource group or select NULL to create new resource group. | `string` | `null` | no |
| <a name="input_https_certificate"></a> [https\_certificate](#input\_https\_certificate) | SSL certificate required for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_https_privatekey"></a> [https\_privatekey](#input\_https\_privatekey) | SSL privatekey (optional) for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_hugging_face_access_token"></a> [hugging\_face\_access\_token](#input\_hugging\_face\_access\_token) | The value of hugging face user access token to access the model repository from huggingface registry | `string` | `null` | no |
| <a name="input_hugging_face_model_name"></a> [hugging\_face\_model\_name](#input\_hugging\_face\_model\_name) | Provide the model path from hugging face registry only. If you have model in COS use the COS configuration variables | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The VPC custom image id of RHEL AI to use while creating a GPU VSI instance. This is optional if you are creating custom image using the image\_url | `string` | `null` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | A COS url location where RHEL AI image is downloaded and stored from Red Hat. This will create custom image. The COS url should be of the format cos://<region>/<bucket-name>/<image-object-name>. This is optional if you have existing custom image\_id. | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to be created. Please provide NVIDIA GPU based machine type to run the solution | `string` | n/a | yes |
| <a name="input_model_apikey"></a> [model\_apikey](#input\_model\_apikey) | Model API Key to setup authorization while inferencing the model | `string` | `null` | no |
| <a name="input_model_cos_bucket_crn"></a> [model\_cos\_bucket\_crn](#input\_model\_cos\_bucket\_crn) | Provide Bucket instance CRN. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_model_cos_bucket_name"></a> [model\_cos\_bucket\_name](#input\_model\_cos\_bucket\_name) | Provide the COS bucket name where you model files reside. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_model_cos_region"></a> [model\_cos\_region](#input\_model\_cos\_region) | Provide COS region where the model bucket reside. If you are using model registry then this field should be empty | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all resources created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where resources are created. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public ssh key is required to the private key that you have generated from. This is used for RHEL AI VSI instance | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH Private Key to login and update model config and execute service operations. Use the private key of SSH public key provided to the VSI instance | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | An existing subnet id where the RHEL AI instance will be deployed. This is optional if you want to create RHEL AI instance in a new subnet and VPC | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone where the RHEL AI instance needs to be deployed. | `number` | n/a | yes |

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
