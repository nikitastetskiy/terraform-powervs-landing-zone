############################
# Landing Zone: VPC & Subnet
############################

resource "ibm_is_vpc" "vpc_edge" { # Create the VPC
  name                        = "${var.prefix}-vpc-edge"
  resource_group              = var.resource_group
  default_security_group_name = "${var.prefix}-security-group-edge"
  default_network_acl_name    = "${var.prefix}-acl-edge"
  default_routing_table_name  = "${var.prefix}-routing-edge"
  address_prefix_management   = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_edge_prefix" { # Reserve an address prefix within the VPC
  name = "${var.prefix}-vpc-edge-prefix"
  vpc  = ibm_is_vpc.vpc_edge.id
  zone = var.vpc_zone
  cidr = var.vpc_cidr_block
}

resource "ibm_is_subnet" "subnet_edge" { # Create a subnet within that prefix
  name            = "${var.prefix}-subnet-edge"
  resource_group  = var.resource_group
  vpc             = ibm_is_vpc.vpc_edge.id
  zone            = var.vpc_zone
  ipv4_cidr_block = var.vpc_cidr_block
  depends_on      = [ibm_is_vpc_address_prefix.vpc_edge_prefix]
}

##########################
# Test VSI (Optional)
##########################

resource "ibm_is_ssh_key" "key_edge" { # SSH key to inject into your test VM
  name       = "${var.prefix}-ssh-key-edge"
  public_key = file(var.ssh_file_public_key)
}

data "ibm_is_image" "catalog_images" { # Data‐source: pick a public image for your test VM
  name = "ibm-ubuntu-20-04-6-minimal-amd64-8"
}

resource "ibm_is_instance" "vsi_edge" { # Create the test VM only if deploy_vsi = true
  count          = var.deploy_vsi ? 1 : 0
  name           = "${var.prefix}-vsi-edge"
  resource_group = var.resource_group
  image          = data.ibm_is_image.catalog_images.id
  profile        = "bx2-2x8"
  vpc            = ibm_is_vpc.vpc_edge.id
  zone           = var.vpc_zone

  primary_network_interface {
    subnet = ibm_is_subnet.subnet_edge.id
  }

  boot_volume {
    name = "boot-volume-vsi-edge"
  }

  keys = [ibm_is_ssh_key.key_edge.id]

}

resource "ibm_is_floating_ip" "f_ip" { # Optionally assign a floating IP
  count          = var.deploy_vsi ? 1 : 0
  name           = "${var.prefix}-floating-ip"
  resource_group = var.resource_group
  target         = ibm_is_instance.vsi_edge[0].primary_network_interface[0].id
}

######################
# Security Group Rule
######################

data "ibm_is_security_group" "security_group" { # Fetch the default security group
  name = ibm_is_vpc.vpc_edge.default_security_group_name
}

resource "ibm_is_security_group_rule" "security_group_rule_icmp_any" { # Allow ICMP inbound for network diagnostics
  group     = data.ibm_is_security_group.security_group.id
  direction = "inbound"
  icmp {
  }
}
