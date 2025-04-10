#
# Developer tips:
#   - Below code should be replaced with the code for the root level module
#

locals {
  l_vpc_id         = try(length(var.vpc_id), 0) > 0 ? var.vpc_id : null
  l_subnet_id      = try(length(var.subnet_id), 0) > 0 ? var.subnet_id : null
  l_public_gateway = var.subnet_id != null ? data.ibm_is_subnet.existing_subnet[0].public_gateway : null
}

##############################################################################
# Create VPC and Subet
##############################################################################

data "ibm_is_subnet" "existing_subnet" {
  count      = var.subnet_id != null ? 1 : 0
  identifier = var.subnet_id
}

resource "ibm_is_vpc" "rhelai_vpc" {
  count          = local.l_vpc_id == null ? 1 : 0
  name           = "${var.prefix}-rhelai-vpc"
  resource_group = var.resource_group_id
}

resource "ibm_is_public_gateway" "rhelai_publicgateway" {
  count          = local.l_public_gateway == null ? 1 : 0
  name           = "${var.prefix}-rhelai-gateway"
  resource_group = var.resource_group_id
  vpc            = try(ibm_is_vpc.rhelai_vpc[0].id, var.vpc_id)
  zone           = var.zone
}

resource "ibm_is_subnet" "rhelai_subnet" {
  count                    = local.l_subnet_id == null ? 1 : 0
  name                     = "${var.prefix}-rhelai-subnet"
  resource_group           = var.resource_group_id
  vpc                      = try(ibm_is_vpc.rhelai_vpc[0].id, var.vpc_id)
  zone                     = var.zone
  public_gateway           = ibm_is_public_gateway.rhelai_publicgateway[0].id
  total_ipv4_address_count = 16
}

##############################################################################
# Create Security Group
##############################################################################


resource "ibm_is_security_group" "gpu_vsi_sg" {
  name           = "${var.prefix}-sg"
  resource_group = var.resource_group_id
  vpc            = try(ibm_is_vpc.rhelai_vpc[0].id, var.vpc_id)
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

resource "ibm_is_security_group_rule" "rule2_3" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "149.81.123.64/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_2]
}

resource "ibm_is_security_group_rule" "rule2_4" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "149.81.135.64/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_3]
}

resource "ibm_is_security_group_rule" "rule2_5" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.177.210.176/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_4]
}

resource "ibm_is_security_group_rule" "rule2_6" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.177.216.144/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_5]
}

resource "ibm_is_security_group_rule" "rule2_7" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "161.156.138.80/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_6]
}

resource "ibm_is_security_group_rule" "rule2_8" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "159.122.111.224/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_7]
}

resource "ibm_is_security_group_rule" "rule2_9" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "161.156.37.160/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_8]
}

resource "ibm_is_security_group_rule" "rule2_10" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.175.106.64/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_9]
}

resource "ibm_is_security_group_rule" "rule2_11" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.175.138.176/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_10]
}

resource "ibm_is_security_group_rule" "rule2_12" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "141.125.79.160/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_11]
}

resource "ibm_is_security_group_rule" "rule2_13" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "141.125.142.96/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_12]
}

resource "ibm_is_security_group_rule" "rule2_14" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.176.111.64/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_13]
}

resource "ibm_is_security_group_rule" "rule2_15" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "158.176.134.80/28"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_14]
}

resource "ibm_is_security_group_rule" "rule2_16" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "169.45.0.0/16"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_15]
}

resource "ibm_is_security_group_rule" "rule2_17" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "169.46.0.0/15"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_16]
}

resource "ibm_is_security_group_rule" "rule2_18" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "169.48.0.0/12"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_17]
}

resource "ibm_is_security_group_rule" "rule2_19" {
  group     = ibm_is_security_group.gpu_vsi_sg.id
  direction = "inbound"
  remote    = "150.238.230.128/27"
  tcp {
    port_min = 22
    port_max = 22
  }
  depends_on = [ibm_is_security_group_rule.rule2_18]
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
