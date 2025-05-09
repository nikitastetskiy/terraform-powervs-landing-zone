output "floating_ip" {
  value     = var.deploy_vsi ? ibm_is_floating_ip.f_ip[0].address : null
}