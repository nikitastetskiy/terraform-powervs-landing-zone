##############################
# 1. Core Resource Group
##############################

resource "ibm_resource_group" "rg" { # Resource group
  name     = "${var.prefix}-rg"
}

##############################
# 2. VPC & (Optional) Test VSI
##############################

module "vpc" {
  source = "./modules/vpc"
  resource_group = ibm_resource_group.rg.id
  prefix = var.prefix
  vpc_region = var.vpc_region
  vpc_zone = var.vpc_zone
  ssh_file_public_key = var.ssh_file_public_key
  vpc_cidr_block = var.vpc_cidr_block
  deploy_vsi = var.deploy_vsi
}

##############################
# 3. Networking (Subnets & Security)
##############################

module "network" {
  depends_on = [ module.vpc ]
  source = "./modules/network"
  resource_group = ibm_resource_group.rg.id
  prefix = var.prefix
  vpc_region = var.vpc_region
  vpc_zone = var.vpc_zone
  subnet_id = module.vpc.edge_subnet_id
  security_group_id = module.vpc.default_security_group_id
}

##############################
# 4. PowerVS Workspace & Instance
##############################

module "powervs" {
  source = "./modules/powervs"
  resource_group = ibm_resource_group.rg.id
  prefix = var.prefix
  ibmcloud_api_key = var.ibmcloud_api_key
  ssh_file_public_key = var.ssh_file_public_key
}

###################################
# 5. Transit Gateway & Connections
###################################

resource "ibm_tg_gateway" "tg_gw"{
  name="${var.prefix}-tgw"
  resource_group = ibm_resource_group.rg.id
  location = var.vpc_region
  global=true
}

resource "ibm_tg_connection" "tg_vpc_connection" {
  gateway      = ibm_tg_gateway.tg_gw.id
  network_type = "vpc"
  name = "vpc"
  network_id   = module.vpc.vpc_edge_crn
}

resource "ibm_tg_connection" "tg_pvs_connection" {
  gateway      = ibm_tg_gateway.tg_gw.id
  network_type = "power_virtual_server"
  name = "power_virtual_server"
  network_id   = module.powervs.powervs_workspace_crn
}