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
