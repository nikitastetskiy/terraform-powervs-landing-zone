variable "prefix" {
  description = "Prefix for all resources to ensure uniqueness"
  type = string
}

variable "powervs_zone" {
  description = "Zone for PowerVS resources in MAD02"
  type        = string
  default     = "mad04"
}

variable "resource_group" {
  description = "The ID of the resource group"
  type        = string
}

variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API key"
  sensitive   = true
}
