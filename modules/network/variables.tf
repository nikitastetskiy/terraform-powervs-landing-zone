variable "prefix" {
  description = "A short, unique prefix applied to all resource names (e.g. \"tf\")."
  type        = string
}

variable "vpc_region" {
  description = "IBM Cloud region where the VPC and related resources will be created (e.g. \"eu-de\")."
  type        = string
}

variable "vpc_zone" {
  description = "Availability zone within the VPC region for zonal resources (e.g. \"eu-de-3\")."
  type        = string
}

variable "resource_group" {
  description = "The IBM Cloud Resource Group ID under which all resources should be provisioned."
  type        = string
}

variable "ca_vpn_server" {
  description = <<-EOT
    The name to assign to the root Certificate Authority (CA) in Secrets Manager.  
    This CA becomes the trust anchor for all VPN certificates.  
    Must match the value referenced by the private-cert-engine module.
  EOT
  type        = string
  default     = "root-ca-vpn-server"
}

variable "certificate_template_name" {
  description = <<-EOT
    The certificate template name to use when issuing end-entity certificates.  
    Defined in the private-cert-engine module and used by both server and client cert modules.
  EOT
  type        = string
  default     = "template-vpn-server"
}

variable "private_cert" {
  description = <<-EOT
    Base name for the private certificate secret in Secrets Manager (used if importing an existing cert).  
    Not used when issuing new certificates via the private-cert modules.
  EOT
  type        = string
  default     = "vpn-private-cert"
}

variable "subnet_id" {
  description = "The VPC Subnet ID in which the VPN Server will be deployed."
  type        = string
}

variable "security_group_id" {
  description = "The VPC Security Group ID where the VPN Server’s interface will receive traffic."
  type        = string
}

variable "secrets_manager_guid" {
  description = <<-EOT
    (Optional) GUID of an existing Secrets Manager instance to use.  
    If empty, a new trial-plan Secrets Manager will be created.  
    Supply this to skip creation and reference an existing SM.
  EOT
  type        = string
  default     = ""
}
