variable "prefix" {
  description = "Prefix for all resources to ensure uniqueness"
  type = string
}

variable "vpc_region" {
  description = "Region for VPC resources"
  type        = string
}

variable "vpc_zone" {
  description = "Zone for VPC resources"
  type        = string
}

variable "resource_group" {
  description = "The ID of the resource group"
  type        = string
}

variable "ca_vpn_server" {
  description = "The CA name of the Secrets Manager"
  type        = string
  default = "root-ca-vpn-server"
}

variable "certificate_template_name" {
  description = "The template certificate name of the Secrets Manager"
  type        = string
  default = "template-vpn-server"
}

variable "private_cert" {
  description = "The template certificate name of the Secrets Manager"
  type        = string
  default = "vpn-private-cert"
}

variable "subnet_id" {
  description = "The ID of the subnet used"
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group used in the VPC"
  type        = string
}
