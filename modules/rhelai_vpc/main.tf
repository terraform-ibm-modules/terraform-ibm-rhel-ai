#
# Developer tips:
#   - Below code should be replaced with the code for the root level module
#

##############################################################################
# Create VPC and Subet
##############################################################################

resource "ibm_is_vpc" "rhelai_vpc" {
  name           = "${var.prefix}-rhelai-vpc"
  resource_group = var.resource_group_id
}

resource "ibm_is_public_gateway" "rhelai_publicgateway" {
  name           = "${var.prefix}-rhelai-gateway"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.rhelai_vpc.id
  zone           = var.zone
}

resource "ibm_is_subnet" "rhelai_subnet" {
  name                     = "${var.prefix}-rhelai-subnet"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.rhelai_vpc.id
  zone                     = var.zone
  public_gateway           = ibm_is_public_gateway.rhelai_publicgateway.id
  total_ipv4_address_count = 16
}

##############################################################################
# Create Security Group
##############################################################################


resource "ibm_is_security_group" "gpu_vsi_sg" {
  name           = "${var.prefix}-sg"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.rhelai_vpc.id
}

resource "ibm_is_security_group_rule" "rule1" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  icmp {
  }
  depends_on = [ibm_is_security_group.gpu_vsi_sg]
}

resource "ibm_is_security_group_rule" "rule2_1" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "161.26.0.0/16"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule1]
}

resource "ibm_is_security_group_rule" "rule2_2" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "166.8.0.0/14"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_1]
}

resource "ibm_is_security_group_rule" "rule3" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  tcp {
    port_min = "8443"
    port_max = "8443"
  }
  depends_on = [ibm_is_security_group_rule.rule2_2]
}

resource "ibm_is_security_group_rule" "rule3_1" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  tcp {
    port_min = "8000"
    port_max = "8000"
  }
  depends_on = [ibm_is_security_group_rule.rule3]
}

resource "ibm_is_security_group_rule" "rule4" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "outbound"
  tcp {
  }
  depends_on = [ibm_is_security_group_rule.rule3_1]
}

resource "ibm_is_security_group_rule" "rule5" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "outbound"
  udp {
  }
  depends_on = [ibm_is_security_group_rule.rule4]
}

resource "ibm_is_security_group_rule" "rule6" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "outbound"
  icmp {
  }
  depends_on = [ibm_is_security_group_rule.rule5]
}
