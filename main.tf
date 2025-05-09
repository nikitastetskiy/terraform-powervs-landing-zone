resource "ibm_resource_group" "rg" { # Resource group
  name     = "${var.prefix}-rg"
}

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