### GENERAL

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key"
  sensitive   = true
}

variable "prefix" {
  description = "Prefix for all resources to ensure uniqueness"
  type = string
  default = "mod"
}

### VPC

variable "vpc_region" {
  description = "Region for VPC resources"
  type        = string
  default     = "eu-es"
}

variable "vpc_zone" {
  description = "Zone for VPC resources"
  type        = string
  default     = "eu-es-2"
}

variable "ssh_file_public_key" {
  description = "Public SSH Key for VSI test. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
  default = "~/.ssh/id_rsa.pub"
}

variable "vpc_cidr_block" {
  description = "Your block of IPs for the VPC"
  type        = string
  default     = "10.0.0.0/24"
}

variable "deploy_vsi" {
  description = "If marked as true, then the VSI is deployed"
  type        = bool
  default = false
}

### VPN client-to-site + Secrets Manager