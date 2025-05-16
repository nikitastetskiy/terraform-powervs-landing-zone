output "test_vsi_floating_ip" {
  description = <<-EOT
    The public floating IP address automatically assigned to the test VSI,  
    when deploy_vsi = true.  
    If no VSI was created (deploy_vsi = false), this value will be null.
  EOT
  value       = var.deploy_vsi ? ibm_is_floating_ip.f_ip[0].address : null
}

output "test_vsi_private_ip" {
  description = <<-EOT
    The private floating IP address of the test VSI,  
    when deploy_vsi = true.  
    If no VSI was created (deploy_vsi = false), this value will be null.
  EOT
  value       = var.deploy_vsi ? ibm_is_instance.vsi_edge[0].primary_network_interface[0].primary_ip[0].address : null
}

output "edge_subnet_id" {
  description = "The identifier of the subnet created within the VPC."
  value       = ibm_is_subnet.subnet_edge.id
}

output "default_security_group_id" {
  description = "The ID of the default security group associated with the VPC."
  value       = data.ibm_is_security_group.security_group.id
}

output "vpc_edge_crn" {
  description = "The Cloud Resource Name (CRN) of the edge VPC."
  value       = ibm_is_vpc.vpc_edge.crn
}
