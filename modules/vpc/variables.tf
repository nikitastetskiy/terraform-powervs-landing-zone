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

variable "ssh_file_public_key" {
  description = "Public SSH Key for VSI test. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "vpc_cidr_block" {
  description = "Your block of IPs for the VPC"
  type        = string
}

variable "resource_group" {
  description = "The ID of the resource group"
  type        = string
}

variable "deploy_vsi" {
  description = "If marked as true, then the VSI is deployed"
  type        = bool
}