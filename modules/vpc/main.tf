######################
# Landing Zone VPC
######################

resource "ibm_is_vpc" "vpc_edge" { # VPC
  name                        = "${var.prefix}-vpc-edge"
  resource_group              = var.resource_group
  default_security_group_name = "${var.prefix}-security-group-edge"
  default_network_acl_name    = "${var.prefix}-acl-edge"
  default_routing_table_name  = "${var.prefix}-routing-edge"
  address_prefix_management   = "manual"
}

resource "ibm_is_vpc_address_prefix" "vpc_edge_prefix" { # Block of networks VPC
  name = "${var.prefix}-vpc-edge-prefix"
  vpc  = ibm_is_vpc.vpc_edge.id
  zone = var.vpc_zone
  cidr = var.vpc_cidr_block
}

resource "ibm_is_subnet" "subnet_edge" { # Subnet
  name            = "${var.prefix}-subnet-edge"
  resource_group  = var.resource_group
  vpc             = ibm_is_vpc.vpc_edge.id
  zone            = var.vpc_zone
  ipv4_cidr_block = var.vpc_cidr_block
  depends_on = [ ibm_is_vpc_address_prefix.vpc_edge_prefix ]
}

resource "ibm_is_ssh_key" "key_edge" { # Your SSH key
  name       = "${var.prefix}-ssh-key-edge"
  public_key = file(var.ssh_file_public_key)
}

resource "ibm_is_instance" "vsi_edge" { # Only for testing
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

data "ibm_is_image" "catalog_images" { # The testing image chosen
  name = "ibm-ubuntu-20-04-6-minimal-amd64-8"
}

resource "ibm_is_floating_ip" "f_ip" { # Floating IP if needed
  count          = var.deploy_vsi ? 1 : 0
  name           = "${var.prefix}-floating-ip"
  resource_group = var.resource_group
  target         = ibm_is_instance.vsi_edge[0].primary_network_interface[0].id
}

data "ibm_is_security_group" "security_group" { # GET - Security Group
  name = ibm_is_vpc.vpc_edge.default_security_group_name
}

resource "ibm_is_security_group_rule" "security_group_rule_icmp_any" { # Allowing the ICMP rules
  group     = data.ibm_is_security_group.security_group.id
  direction = "inbound"
  icmp {
  }
}
