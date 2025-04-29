## Overview

The architecture provides a RHEL AI instance on IBM Cloud and serves a fine-tuned model as a service with a public end point or a private endpoint. The RHEL AI instance serves a vLLM model using instruct lab.

This documentation has the following sections that describe the architecture and the deployment of RHEL AI on IBM Cloud to inference the model of your choice.

- [Objective](#objective)
- [Reference Architecture](#reference-architecture)
- [Planning](#planning)
    - [ ] [Confirm IBM Cloud Settings](#confirm-your-ibm-cloud-settings)
    - [ ] [Set the IAM permissions](#set-the-iam-permissions)
    - [ ] [Access for IBM Cloud projects](#access-for-ibm-cloud-projects)
- [Deploying RHEL AI on IBM Cloud with a model](#deploying-rhel-ai-on-ibm-cloud-with-a-model)
    - [ ] [STEP-1: Create RHEL AI Project from IBM Cloud Catalog](#step-1-create-rhel-ai-project-from-ibm-cloud-catalog)
    - [ ] [STEP-2: Configure RHEL AI Project](#step-2-configure-the-rhel-ai-project)
    - [ ] [STEP-3: Validate and Deploy](#step-3-validate-and-deploy)
- [Terraform Requirements](#requirements)

### Objective
The objective is to provide a "Quick Start" solution  for users to be able to deploy the RHEL AI instance and validate, test the fine-tuned models on IBM Cloud. The architecture is intended for

- Accelerating the validation and testing of fine tuned models on IBM Cloud RHEL AI instance
- Enable users to bring in their fine tuned model solutions in a secure environment and create demos
- Provide inferencing of the fine tuned models through vLLM API interface

## Reference Architecture

The architecture diagram describes the resources deployed to run models downloaded from Hugging Face or model files available in IBM Cloud Object Storage. The architecture can be a public network connectivity or a private only.

![RHEL AI VPC Architecture Diagram](../../reference-architecture/rhelai-vpc.svg)

**Steps that show case the deployment automation**

1. Provision a VSI instance in a VPC using RHEL AI image and NVIDIA accelerated GPU compute
2. Download the model from Hugging Face or from COS bucket and serve the model using Instruct lab
3. Optionally enable secure SSL connection if required to inference the model. You have the option to restrict the network connectivity to private only and block all the traffic coming from public network

### Solution Components

| Category | Solution components | How it is used in the solution |
| -------- | ------------------- | ------------------------------ |
| Compute  | NVIDIA GPUs         | The deployable architecture provides only two compute profiles, a gx3-24x120x1l40s with single l40 GPU or gx3-48x240x2l40s with 2 GPUs. Depending on the size of the model select the compute profile |
|          | RHEL AI Image       | A RHEL AI image with version 1.4 and above |
| Storage  | Boot Volume         | A 250 GB boot volume storage to run the model |
|          | Cloud Object Storage | Model files downloaded from IBM Cloud Object storage. This is not provisioned by Deployable Architecture but required when downloading models from IBM COS bucket |
| Networking | Virtual Private Clouds (VPCs), Subnets, Security Groups (SGs) | VPCs for RHEL AI instance isolation Subnets, SGs for restricted access to model service |
|            | Public Gateway  | Egress traffic to allow RHEL AI instance to access Hugging Face registry |
|            | Floating IP     | Access to inference models on port 8000 for http and 8443 for https |
|            | SSL Connection  | Enable Https using a proxy service |
| Security   | Access management | IBM Cloud Identity & Access Management |

### Solution Requirements

The following table represents a typical set of requirements for RHEL AI deployment on IBM Cloud

| Aspect | Requirements |
| ------ | ------------ |
| Compute | Select one of the two NVIDIA GPU accelerated computes, a l40 GPU or  2l40 GPUs |
| Networking | Deploy workloads in an secure environment with Security Groups in place |
| Security | Help ensure that all operation actions run securely. |


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

Your Access Group should look like this

![AcessGroup_Picture](../../reference-architecture/images//Picture5.png)

### Access for IBM Cloud projects

You can use IBM Cloud projects as a deployment option. Projects are designed with infrastructure as code and compliance in mind to help ensure that your projects are managed, secure, and always compliant. For more information, see [Learn about IaC deployments with projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

You need the following access to create a project and create project tooling resources within the account. Make sure you have the following access:

- The Editor role on the Projects service.
- The Editor and Manager role on the Schematics service
- The Viewer role on the resource group for the project

For more information, see [Assigning users access to projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-access-project).

Your User Access Policies should look like this

![ProjectAccess_Picture](../../reference-architecture/images//Picture6.png)

## Deploying RHEL AI on IBM Cloud with a model

You can deploy a deployable architecture from the IBM Cloud catalog. You can choose one of several deployment options, including with IBM Cloud projects. [Learn about IaC deployments with projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

To deploy a RHEL AI deployable architecture through the IBM Cloud catalog, follow these steps:

### STEP-1: Create RHEL AI Project from IBM Cloud Catalog

a. Go to the IBM Cloud [catalog](https://cloud.ibm.com/catalog#reference_architecture) and search for `RHEL AI on IBM Cloud with model inferencing`. Click the tile for details

b. Select the latest product version in Architecture section and click "Add to project". Create new project by providing Name, Configuration Name, Region and Resource Group. Click Create button after filling the required fields

### STEP-2: Configure the RHEL AI project

In this section, we will configure the DA.

#### Security Fields tab with Details

Under "Security" tab, provide the IBM Cloud API key created in the planning section under Set the IAM permissions. If you have the API Key stored in Secrets Manager you can select the API Key from the secrets manager using the key icon <img src="../../reference-architecture/images//Picture3.png" width="80" height="20">

![Security-Config-Image](../../reference-architecture/images//Picture1.png)

Now, proceed to the **Required fields** tab and fill in any additional relevant information as needed based on your configuration selections.

#### Required Fields tab with Details

![Required-Fields-Image](../../reference-architecture/images//Picture2.png)
Click on `i` icon for more details about the fields.

1. **prefix**:
* This unique identifier helps distinguish resource names during provisioning, formatted as {prefix}-{resource-name}. For instance, with the prefix `rhelai`, the resource group name would be `rhelai-rg`.

2. **existing_resource_group** (Optional):
* If you already have an existing resource group, select it from this dropdown. If not, choose "null" to automatically create a new one using your specified prefix, like "{prefix}-rg".

3. **region**:
* Choose the desired geographical area for resource deployment from the provided list of regions.

4. **zone**:
* Select the specific zone within your chosen region where you want to provision the Virtual Server Instance (VSI).

5. **machine_type**:
* Opt for the GPU profile suitable for your needs. There are two choices:
    * 1 x NVIDIA L40S 48 GB <br>
    * 2 x NVIDIA L40S 48 GB

6. **ssh_key** (Required):
* You must provide a public SSH key to prepare and configure the RHEL AI instance during initialization. This can be generated using tools like OpenSSH in your local machine or an external key management system.

7. **ssh_private_key** (Required):
* Alongside the public SSH key, supply a private key for secure access to the RHEL AI instance during model configuration setup. Generate this key pair locally or externally ensuring it's either RSA or ED2519 with 2048-bit or 4096-bit key size. For Mac users who may default to 3072-bit keys, adjust using these commands: <br>
    * For RSA keys: `ssh-keygen -t rsa -b 2048 -C "user_ID"` <br>
    * For ED25519 keys: `ssh-keygen -t ed25519 -b 2048 -C "user_ID"`

Now, proceed to the **Optional fields** tab and fill in any additional relevant information as needed based on your configuration selections.

#### Optional Fields tab with Details

![Optional-Fields-Image](../../reference-architecture/images//Picture4.png)

Click on `i` icon for more details about the fields.

1. **subnet_id**:
* If you have an existing subnet, enter its ID to deploy the RHEL AI instance within it. <br>
* Note: This field is optional and has no constraints; use it only if needed.

2. **image_url** (Optional):
* Provide a COS URL where your custom RHEL AI image resides, formatted as
`cos://{region}/{bucket}/{filename}`. Use this if you've created a custom image or want to leverage the latest IBM Cloud NVIDIA-based RHEL AI image from Red Hat's COS bucket. <br>
* Instructions for obtaining and uploading the image: <br>
    * Download [RHEL AI for NVIDIA on IBM Cloud](https://developers.redhat.com/products/rhel-ai/download) from Red Hat (you may need to create a [Red Hat account](https://sso.redhat.com/auth/realms/redhat-external/protocol/openid-connect/auth?response_type=code&client_id=rhd-dm&redirect_uri=https%3A%2F%2Fdevelopers.redhat.com%2Fcontent-gateway%2Frest%2Fkeycloak&state=edaacce8-f115-473d-b87a-ba0cec4f197f&login=true&scope=openid+rhdsupportable)). <br>
* Upload the QCOW image to an existing or newly created IBM Cloud [Object Storage (COS)](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-secure-content-store) bucket using tools like IBM Aspera or [minio client](https://min.io/docs/minio/linux/reference/minio-mc.html) for faster uploads. <br>
* Note: You must provide either `image_id` (see below) or `image_url`.

3. **image_id** (Optional):
* The ID of a pre-existing VPC custom image of RHEL AI in your cloud resources to use when creating a GPU VSI instance. Use this field if you've already created and stored a custom image. <br>
* Note: Provide either `image_id` or `image_url`.

4. **enable_private_only** (Default: true):
* Set to `true` for private IP-only access with no public internet connectivity. If set to `false`, your model service will be accessible using HTTP or HTTPS. <br>
* Note: Ensures your VSI instance is restricted to a private network if set to `true`.

5. **hugginface_model_name** (Optional):
* Enter the model name from the Hugging Face registry; the model will be downloaded from the repository. Use this field only if you don't have your model in COS. <br>
* Instructions for obtaining a Hugging Face user access token: Follow the instructions provided in [User access tokens](https://huggingface.co/docs/api_auto/main).

6. **hugging_face_access_token** (Optional):
* Provide your Hugging Face [User access tokens](https://huggingface.co/docs/hub/en/security-tokens) to access the model repository from the Hugging Face registry. Use this field only if you've provided `hugginface_model_name`. <br>
* Note: This field is optional when using `model_cos_bucket_name`, `model_cos_region`, and `model_cos_bucket_crn`.

7. **model_cos_bucket_name**, **model_cos_region**, **model_cos_bucket_crn** (Optional):
* If you have your model stored in IBM Cloud Object Storage, provide the bucket name, region, and instance CRN respectively. Use these fields only when `hugginface_model_name` and `hugging_face_access_token` are not used.

8. **enable_https** (Optional):
* Enable secure SSL by hosting an HTTPS service to your model service, creating a proxy nginx with HTTPS certificates. Set this to `true` if you want to access the model service using HTTPS.
* Instructions for generating self-signed SSL certificates for development: Follow: [Using OpenSSL to generate and format certificates](https://www.ibm.com/docs/en/api-connect/10.0.x_cd?topic=profile-using-openssl-generate-format-certificates).

9. **https_certificate**, **https_privatekey**: (Required if `enable_https` is true):
* Provide the SSL certificate and private key required for HTTPS setup. Store the certificate file and private key file securely.

10. **model_apikey**:
* A model API key to set up authorization during model inference. Generate your own model API key independently.

#### Saving Configurations

After entering all relevant fields, click "Save" to store the project configurations for your Deployable Architecture. You can find the complete list of fields under [Inputs](#inputs).

### STEP-3: Validate and deploy

a. After you save the configuration, click Validate to validate the generated plan. Once the validation is successful you can review the cost breakdown of resources that gets deployed. If the validation is unsuccessful then click on the Validation Failed to see the logs. If there are any empty fields (you may need to revert them back to null) or if there are other issues in your configuration click "Edit" button to go back to configuration to edit the required and optional fields and save and validate again until its successful. If you still have issue contact the support team.

After validating and verifying the cost estimate, you can approve by providing the comments and clicking the button Approve

b. Once you are ready, you can click Deploy button to provision the resources. You can click view logs to see what resources are getting provisioned. If for some reason deployment fails you can verify the logs and report the errors to support team.

c. Once the deployment is successful, you can check the output of the deployment by clicking on "Changes deployed successfully". You see the summary of resources deployed

d. Click on View Resources button to see resources that got deployed and active

e. Change the tab to Outputs to view model details and the RHEL AI VSI details. You see a model_url in the outputs when you selected enable_private field as false (if enable_private is true then the model_url is empty in outputs). Click on the model_url to see the API documentation to inference the model

f. To undeploy the resources click on the "more options" (:) menu on the top right corner beside Edit button and you see undeploy option. Click the undeploy button to destroy all the resources including the resource group.


By following the 3 steps - Create Project, Configure RHEL AI Project, Validate and Deploy you have successfully provisioned a RHEL AI instance with a model to inference securely on IBM Cloud through automation.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.77.1, < 2.0.0 |

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
| <a name="input_enable_https"></a> [enable\_https](#input\_enable\_https) | Enable https to your model service? If yes then a proxy nginx with https certificates will be created. https\_cerificate and https\_privatekey are required when true | `bool` | `false` | no |
| <a name="input_enable_private_only"></a> [enable\_private\_only](#input\_enable\_private\_only) | A flag to determine to have private IP only and no public network accessibility | `bool` | `true` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Select the name of a existing resource group or select null to create new resource group. | `string` | `null` | no |
| <a name="input_https_certificate"></a> [https\_certificate](#input\_https\_certificate) | SSL certificate required for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_https_privatekey"></a> [https\_privatekey](#input\_https\_privatekey) | SSL privatekey for https setup. Required if enable\_https is true | `string` | `""` | no |
| <a name="input_hugging_face_access_token"></a> [hugging\_face\_access\_token](#input\_hugging\_face\_access\_token) | The value of hugging face user access token to access the model repository from huggingface registry. If you have model in COS, then this is optional. Use the COS configuration variables model\_cos\_bucket\_name, model\_cos\_region and model\_cos\_bucket\_crn | `string` | `null` | no |
| <a name="input_hugging_face_model_name"></a> [hugging\_face\_model\_name](#input\_hugging\_face\_model\_name) | Provide the model path from hugging face registry only. If you have model in COS use the COS configuration variables model\_cos\_bucket\_name, model\_cos\_region and model\_cos\_bucket\_crn | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | The VPC custom image id of RHEL AI to use while creating a GPU VSI instance. This is optional if you are creating custom image using the image\_url | `string` | `null` | no |
| <a name="input_image_url"></a> [image\_url](#input\_image\_url) | A COS url location where RHEL AI image is downloaded from Red Hat and stored in COS. This will create custom image. The COS url should be of the format cos://{region}/{bucket}/{filename}. This is optional if you have existing custom image\_id. | `string` | `null` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to be created. Please select one of the NVIDIA GPU based machine type to run the solution | `string` | n/a | yes |
| <a name="input_model_apikey"></a> [model\_apikey](#input\_model\_apikey) | Model API Key to setup authorization while inferencing the model | `string` | `null` | no |
| <a name="input_model_cos_bucket_crn"></a> [model\_cos\_bucket\_crn](#input\_model\_cos\_bucket\_crn) | Provide Bucket instance CRN. If you are using hugging\_face\_model\_name and hugging\_face\_access\_token then this field is optional | `string` | `null` | no |
| <a name="input_model_cos_bucket_name"></a> [model\_cos\_bucket\_name](#input\_model\_cos\_bucket\_name) | Provide the COS bucket name where you model files reside. If you are using hugging\_face\_model\_name and hugging\_face\_access\_token then this field is optional | `string` | `null` | no |
| <a name="input_model_cos_region"></a> [model\_cos\_region](#input\_model\_cos\_region) | Provide COS region where the model bucket reside. If you are using hugging\_face\_model\_name and hugging\_face\_access\_token then this field is optional | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix to append to all resources created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region where resources are created. | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A public ssh key is required that you have generated from. This is used for RHEL AI VSI instance | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH Private Key that was generated to login and update model config and execute service operations. Use the private key of SSH public key provided in ssh\_key. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | An existing subnet id where the RHEL AI instance will be deployed. This is optional and can be set to null if you want to create RHEL AI instance in a new subnet and VPC | `string` | `null` | no |
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
