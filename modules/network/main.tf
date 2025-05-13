############################
# 1. Secrets Manager (trial)
############################

# resource "ibm_resource_instance" "secrets_manager" {
#   name              = "${var.prefix}-secrets-manager"
#   service           = "secrets-manager"
#   plan              = "trial"
#   location          = var.vpc_region
#   resource_group_id = var.resource_group
#   parameters = {
#     service-endpoints: "public-and-private"
#   }
# }

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.2.6"
  resource_group_id    = var.resource_group
  region               = var.vpc_region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "trial"
  allowed_network    = "public-and-private"
}

###################
# 2. Secrets Group
###################

resource "ibm_sm_secret_group" "vpn_group" {
  name        = "${var.prefix}-vpn-secrets"
  instance_id = module.secrets_manager.secrets_manager_guid
  region = var.vpc_region
  endpoint_type = "public"
}

module "private_secret_engine" {
  depends_on = [ibm_sm_secret_group.vpn_group]
  source                    = "terraform-ibm-modules/secrets-manager-private-cert-engine/ibm"
  version                   = "1.4.0"
  secrets_manager_guid      = module.secrets_manager.secrets_manager_guid
  region                    = var.vpc_region
  root_ca_name              = var.ca_vpn_server
  root_ca_common_name       = "terraform-modules.ibm.com"
  root_ca_max_ttl           = "8760h"
  intermediate_ca_name      = "intermediate-ca-vpn-server"
  certificate_template_name = var.certificate_template_name
}

module "vpn_server_cert" {
  source                 = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version                = "1.3.3"
  depends_on             = [ module.private_secret_engine ]
  cert_name              = "${var.prefix}-vpn-server-cert"
  cert_description       = "TLS Certificate for VPN Server"
  cert_secrets_group_id  = ibm_sm_secret_group.vpn_group.secret_group_id
  cert_template          = var.certificate_template_name
  cert_common_name       = "vpn.terraform-modules.ibm.com"
  secrets_manager_guid   = module.secrets_manager.secrets_manager_guid
  secrets_manager_region = var.vpc_region
}

# 3) Client cert – same module, just different name and CN
module "vpn_client_cert" {
  source                 = "terraform-ibm-modules/secrets-manager-private-cert/ibm"
  version                = "1.3.3"
  depends_on             = [ module.private_secret_engine ]
  cert_name              = "${var.prefix}-vpn-client-cert"
  cert_description       = "TLS Certificate for VPN Client"
  cert_secrets_group_id  = ibm_sm_secret_group.vpn_group.secret_group_id
  cert_template          = var.certificate_template_name
  cert_common_name       = "client.terraform-modules.ibm.com"
  secrets_manager_guid   = module.secrets_manager.secrets_manager_guid
  secrets_manager_region = var.vpc_region
}

data "ibm_sm_private_certificate" "vpn_server_cert" {
  depends_on = [module.vpn_server_cert]
  instance_id   = module.secrets_manager.secrets_manager_guid
  region = var.vpc_region
  name        = "${var.prefix}-vpn-server-cert"
  secret_group_name = ibm_sm_secret_group.vpn_group.name
}

data "ibm_sm_private_certificate" "vpn_client_cert" {
  depends_on = [module.vpn_client_cert]
  instance_id   = module.secrets_manager.secrets_manager_guid
  region = var.vpc_region
  name        = "${var.prefix}-vpn-client-cert"
  secret_group_name = ibm_sm_secret_group.vpn_group.name
}

# resource "ibm_iam_authorization_policy" "policy" {
# source_service_name = "ibm_is_vpn_server"
# target_service_name = "secrets-manager"
# roles               = ["Reader"]
# description         = "Authorization Policy"
# transaction_id     = "terraformAuthorizationPolicy"
# }

# ######################
# # VPN client-to-site
# ######################

resource "ibm_iam_authorization_policy" "policy" {
  depends_on = [data.ibm_sm_private_certificate.vpn_server_cert]
  source_service_name         = "is"
  source_resource_type        = "vpn-server"
  source_resource_group_id    = var.resource_group
  target_service_name         = "secrets-manager"
  target_resource_instance_id = module.secrets_manager.secrets_manager_guid
  roles                       = ["SecretsReader"]
  description                 = "Allow all VPN server instances in the resource group ${var.resource_group} to read from the Secrets Manager instance with ID ${module.secrets_manager.secrets_manager_guid}"
}

resource "ibm_is_vpn_server" "vpn_client" {
  name           = "${var.prefix}-ipsec-policy"
  resource_group = var.resource_group
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

resource "ibm_is_vpn_server_route" "vpn_client_route_vpc" {
  vpn_server    = ibm_is_vpn_server.vpn_client.vpn_server
  destination   = "10.0.0.0/24"
  action        = "translate"
  name          = "vpn-vpc-server-route"
}

resource "ibm_is_vpn_server_route" "vpn_client_route_powervs" {
  vpn_server    = ibm_is_vpn_server.vpn_client.vpn_server
  destination   = "10.0.10.0/24"
  action        = "translate"
  name          = "vpn-powervs-server-route"
}

resource "ibm_is_vpn_server_route" "vpn_client_route_powervs_test" {
  vpn_server    = ibm_is_vpn_server.vpn_client.vpn_server
  destination   = "10.0.20.0/24"
  action        = "translate"
  name          = "vpn-powervs-server-route-test"
}

resource "ibm_is_security_group_rule" "security_rule_vpn" {
  group = var.security_group_id
  direction  = "inbound"
  remote = "0.0.0.0/0"
  local = ibm_is_vpn_server.vpn_client.private_ips[0].address
  udp {
    port_min = 443
    port_max = 443
  }
}

data "ibm_sm_private_certificate_configuration_root_ca" "root_ca" {
  instance_id   = module.secrets_manager.secrets_manager_guid
  region        = var.vpc_region
  name = var.ca_vpn_server
}

output "x" {
  value = data.ibm_sm_private_certificate_configuration_root_ca.root_ca
}

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