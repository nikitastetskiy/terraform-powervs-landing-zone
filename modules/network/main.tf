############################
# 1. Secrets Manager (trial)
############################

module "secrets_manager" { # Conditionally create a new Secrets Manager if no GUID was provided
  count                = var.secrets_manager_guid == "" ? 1 : 0
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.2.6"
  resource_group_id    = var.resource_group
  region               = var.vpc_region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "trial"
  allowed_network      = "public-and-private"
}

locals { # Determine final SM GUID: use user‐supplied or the newly created one
  secrets_manager_guid = var.secrets_manager_guid != "" ? var.secrets_manager_guid : (
    length(module.secrets_manager) > 0 ?
    module.secrets_manager[0].secrets_manager_guid :
    ""
  )
}

###################
# 2. Secrets Group
###################

resource "ibm_sm_secret_group" "vpn_group" { # Group to hold all VPN-related secrets
  name          = "${var.prefix}-vpn-secrets"
  instance_id   = local.secrets_manager_guid
  region        = var.vpc_region
  endpoint_type = "public"
}

#########################################
# 3. Private Cert Engine (Root & Inter CA)
#########################################

module "private_secret_engine" { # Bootstraps a Root CA + Intermediate CA inside Secrets Manager
  depends_on                = [ibm_sm_secret_group.vpn_group]
  source                    = "terraform-ibm-modules/secrets-manager-private-cert-engine/ibm"
  version                   = "1.4.0"
  secrets_manager_guid      = local.secrets_manager_guid
  region                    = var.vpc_region
  root_ca_name              = var.ca_vpn_server
  root_ca_common_name       = "terraform-modules.ibm.com"
  root_ca_max_ttl           = "8760h"
  intermediate_ca_name      = "intermediate-ca-vpn-server"
  certificate_template_name = var.certificate_template_name
}

################################################
# 4. Issue Server & Client Certificates Modules
################################################

module "vpn_server_cert" { # Server certificate for the VPN gateway
  depends_on             = [module.private_secret_engine]
  source                 = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version                = "1.3.3"
  cert_name              = "${var.prefix}-vpn-server-cert"
  cert_description       = "TLS Certificate for VPN Server"
  cert_secrets_group_id  = ibm_sm_secret_group.vpn_group.secret_group_id
  cert_template          = var.certificate_template_name
  cert_common_name       = "vpn.terraform-modules.ibm.com"
  secrets_manager_guid   = local.secrets_manager_guid
  secrets_manager_region = var.vpc_region
}

module "vpn_client_cert" { # Client certificate for VPN users
  depends_on             = [module.private_secret_engine]
  source                 = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version                = "1.3.3"
  cert_name              = "${var.prefix}-vpn-client-cert"
  cert_description       = "TLS Certificate for VPN Client"
  cert_secrets_group_id  = ibm_sm_secret_group.vpn_group.secret_group_id
  cert_template          = var.certificate_template_name
  cert_common_name       = "client.terraform-modules.ibm.com"
  secrets_manager_guid   = local.secrets_manager_guid
  secrets_manager_region = var.vpc_region
}

###############################################
# 5. Retrieve issued Server & Client cert CRNs
###############################################

data "ibm_sm_private_certificate" "vpn_server_cert" {
  depends_on        = [module.vpn_server_cert]
  instance_id       = local.secrets_manager_guid
  region            = var.vpc_region
  name              = "${var.prefix}-vpn-server-cert"
  secret_group_name = ibm_sm_secret_group.vpn_group.name
}

data "ibm_sm_private_certificate" "vpn_client_cert" {
  depends_on        = [module.vpn_client_cert]
  instance_id       = local.secrets_manager_guid
  region            = var.vpc_region
  name              = "${var.prefix}-vpn-client-cert"
  secret_group_name = ibm_sm_secret_group.vpn_group.name
}

#################################################
# 6. IAM Policy: allow VPN servers to read secrets
#################################################

resource "ibm_iam_authorization_policy" "policy" {
  depends_on                  = [data.ibm_sm_private_certificate.vpn_server_cert]
  source_service_name         = "is"
  source_resource_type        = "vpn-server"
  source_resource_group_id    = var.resource_group
  target_service_name         = "secrets-manager"
  target_resource_instance_id = local.secrets_manager_guid
  roles                       = ["SecretsReader"]
  description                 = "Allow all VPN server instances in the resource group ${var.resource_group} to read from the Secrets Manager instance with ID ${local.secrets_manager_guid}"
}

#################################
# 7. Create the VPN Server itself
#################################

resource "ibm_is_vpn_server" "vpn_client" {
  depends_on      = [ibm_iam_authorization_policy.policy]
  name            = "${var.prefix}-ipsec-policy"
  resource_group  = var.resource_group
  certificate_crn = data.ibm_sm_private_certificate.vpn_server_cert.crn
  client_authentication {
    method        = "certificate"
    client_ca_crn = data.ibm_sm_private_certificate.vpn_client_cert.crn
  }
  client_ip_pool         = "10.5.0.0/21"
  client_dns_server_ips  = ["161.26.0.10", "8.8.8.8"]
  client_idle_timeout    = 2800
  enable_split_tunneling = true
  port                   = 443
  protocol               = "udp"
  subnets                = [var.subnet_id]
}

##################################################
# 8. Define security group rule & static routes
##################################################

resource "ibm_is_security_group_rule" "security_rule_vpn" { # Allow UDP/443 from anywhere to the VPN interface
  group     = var.security_group_id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  local     = ibm_is_vpn_server.vpn_client.private_ips[0].address
  udp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_vpn_server_route" "vpn_client_route_vpc" { # Route VPC traffic through the VPN
  vpn_server  = ibm_is_vpn_server.vpn_client.vpn_server
  destination = "10.0.0.0/24"
  action      = "translate"
  name        = "vpn-vpc-server-route"
}

resource "ibm_is_vpn_server_route" "vpn_client_route_powervs" { # Route PowerVS traffic through the VPN
  vpn_server  = ibm_is_vpn_server.vpn_client.vpn_server
  destination = "10.0.10.0/24"
  action      = "translate"
  name        = "vpn-powervs-server-route"
}

#########################################################
# 9. Fetch Root CA config for CA chain inclusion (optional)
#########################################################

data "ibm_sm_private_certificate_configuration_root_ca" "root_ca" {
  depends_on  = [module.private_secret_engine]
  instance_id = local.secrets_manager_guid
  region      = var.vpc_region
  name        = var.ca_vpn_server
}

#####################################################
# 10. Generate local .ovpn client bundle (optional)
#####################################################

resource "local_file" "openvpn_bundle" {
  filename        = "${path.cwd}/${var.prefix}.ovpn"
  file_permission = "0644"

  content = <<-EOT
    client
    dev tun
    proto udp
    remote ${ibm_is_vpn_server.vpn_client.hostname} ${ibm_is_vpn_server.vpn_client.port}
    resolv-retry infinite
    nobind
    persist-key
    persist-tun
    remote-cert-tls server
    cipher AES-256-CBC
    auth SHA256
    verb 3

    <ca>
    ${data.ibm_sm_private_certificate.vpn_client_cert.issuing_ca}
    ${data.ibm_sm_private_certificate_configuration_root_ca.root_ca.data[0].issuing_ca}
    </ca>

    <cert>
    ${data.ibm_sm_private_certificate.vpn_client_cert.certificate}
    </cert>

    <key>
    ${data.ibm_sm_private_certificate.vpn_client_cert.private_key}
    </key>
  EOT
}
