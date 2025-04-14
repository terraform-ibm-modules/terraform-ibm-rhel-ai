# RHEL AI on VPC with fine-tuned model

The Red Hat Enterprise Linux AI (RHEL AI) is a bootable RedHat Enterprise Linux image optimized foundation model platform to develop, test and run large language models. The deployable architecture hosts the RHEL AI with options to meet the user needs. The key features of the architecture pattern are

- Enable to select machine type for the model you would like to host and run the model as a service with Instruct Lab. 
- Download models either from Hugging Face registry or from IBM Cloud Object Storage bucket. 
- Select private only VPC infrastructure and not allow public traffic to inference model internally or enable a Public IP to inference models. 
- Deploy RHEL AI instance and run the models on existing subnet in a VPC. 
- Provision a secure SSL transport connection to inference the models
- Enable authorization using API Key to inference the model
- Secure the RHEL AI instance using Security Groups

```
Note: The architecture supports only RHEL AI images with 1.4 and higher versions
```

## Architecture Diagram

![RHEL AI VPC Architecture Diagram](./rhelai-vpc.svg)

## Solution Components

| Category | Solution components | How it is used in the solution |
| -------- | ------------------- | ------------------------------ |
| Compute  | NVIDIA GPUs         | The deployable architecture provides only two compute profiles, a gx3-24x120x1l40s with single l40 GPU or gx3-48x240x2l40s with 2 GPUs. Depending on the size of the model select the compute profile |
| Storage  | Boot Volume         | A 250 GB boot volume storage to run the model |
|          | Cloud Object Storage | Model files downloaded from IBM Cloud Object storage. This is not provisioned by Deployable Architecture but required when downloading models from IBM COS bucket |
| Networking | Virtual Private Clouds (VPCs), Subnets, Security Groups (SGs) | VPCs for RHEL AI instance isolation Subnets, SGs for restricted access to model service |
|            | Public Gateway  | Egress traffic to allow RHEL AI instance to access Hugging Face registry |
|            | Floating IP     | Access to inference models on port 8000 for http and 8443 for https |
|            | SSL Connection  | Enable Https using a proxy service |
| Security   | Access management | IBM Cloud Identity & Access Management |

## Requirements

The following table represents a typical set of requirements for RHEL AI deployment on IBM Cloud

| Aspect | Requirements |
| ------ | ------------ |
| Compute | Select one of the two NVIDIA GPU accelerated computes, a l40 GPU or  2l40 GPUs |
| Networking | Deploy workloads in an secure environment with Security Groups in place |
| Security | Help ensure that all operation actions run securely. |


