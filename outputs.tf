output "test_vsi_private_ip" {
  description = "The private IP of the test VSI."
  value       = module.vpc.test_vsi_private_ip
}

output "test_vsi_floating_ip" {
  description = "The public floating IP of the test VSI."
  value       = module.vpc.test_vsi_floating_ip
}

output "test_lpar_private_ip" {
  description = "The private IP of the LPAR."
  value       = module.powervs.powervs_instance_ip
}

output "vpn_server_hostname" {
  description = "The hostname or endpoint clients should connect to."
  value       = module.network.vpn_server_hostname
}

output "vpn_server_private_ip" {
  description = "The private IP of the VPN server interface."
  value       = module.network.vpn_server_private_ip
}

output "openvpn_bundle_path" {
  description = "Local path to the generated .ovpn client bundle."
  value       = module.network.openvpn_bundle_path
}

output "powervs_catalog_images" {
  description = <<-EOT
    A human-readable list of all PowerVS catalog images, showing each name, its ID,
    and marking `[selected]` on the one that will be used.
  EOT
  value       = module.powervs.powervs_catalog_images
}

output "delete_secrets_manager_command" {
  description = "Steps to delete the reclaim and then delete the trial Secrets Manager instance via IBM Cloud CLI."
  value       = <<-EOT
    # 1) Find the reclamation request for the SM instance:
    ibmcloud resource reclamations
    
    # 2) Delete the reclaimed resource (replace <RECLAMATION_ID> with the one returned above):
    ibmcloud resource reclamation-delete <RECLAMATION_ID>
  EOT
}
