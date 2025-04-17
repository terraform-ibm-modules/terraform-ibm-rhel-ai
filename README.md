<!-- Update this title with a descriptive name. Use sentence case. -->
# IBM RHEL.ai on IBM Cloud VSI solution

## Overview

The architecture provides a RHEL AI instance on IBM Cloud and serves a fine-tuned model as a service with a public end point or a private endpoint. The RHEL AI instance serves a vLLM model using instruct lab.


## Details

The Deployable Architecture (DA) have different modules to perform IaaC and run Ansible scripts on IBM Cloud.

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


<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-rhel-ai?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-rhel-ai/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This repository contains the following infrastructure as code solutions:
- [RHEL.ai complete solution with VPC](./solutions/rhelai_vpc)

> [!NOTE]
> These solutions are not intended to be called by one or more other modules because they contain a provider configurations. They are not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
