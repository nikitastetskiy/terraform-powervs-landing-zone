output "floating_ip" {
  value     = var.deploy_vsi ? ibm_is_floating_ip.f_ip[0].address : null
}

output "subnet_id" {
  value = ibm_is_subnet.subnet_edge.id
}

output "security_group_id" {
  value = data.ibm_is_security_group.security_group.id
}

output "vpc_edge_crn" {
  value = ibm_is_vpc.vpc_edge.crn
}