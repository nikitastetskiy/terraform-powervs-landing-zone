output "vpn_server_private_ip" {
  description = "The private IP address assigned to the VPN server’s network interface."
  value       = ibm_is_vpn_server.vpn_client.private_ips[0].address
}

output "vpn_server_hostname" {
  description = "Hostname or public endpoint that VPN clients should use to connect."
  value       = ibm_is_vpn_server.vpn_client.hostname
}

output "openvpn_bundle_path" {
  description = "Local path to the generated .ovpn client bundle."
  value       = local_file.openvpn_bundle.filename
}