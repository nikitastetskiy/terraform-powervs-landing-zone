output "delete_command" {
  description = "How to delete the trial Secrets Manager instance"
  value       = "To delete your trial Secrets Manager, run: ibmcloud resource reclamation-delete"
}

output "name" {
  value = data.ibm_sm_private_certificate.vpn_client_cert
}

# output "name" {
#   value = ibm_is_vpn_server.vpn_client.private_ips[0].address
# }

# output "vpn2" {
#   value = ibm_is_vpn_server.vpn_client.hostname
# }