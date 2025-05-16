### GENERAL

variable "ibmcloud_api_key" {
  description = "IBM Cloud IAM API key with permissions to provision all required resources. Keep this secret and do not commit to version control."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.ibmcloud_api_key) >= 32
    error_message = "The IBM Cloud API key must be at least 32 characters long."
  }
}

variable "prefix" {
  description = <<-EOT
    A unique, lowercase prefix to prepend to all resource names to avoid collisions.
    Must start with a letter and may contain only letters, numbers, and hyphens.
    Example: "tf"
  EOT
  type    = string
  default = "hcl"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.prefix))
    error_message = "Prefix must be 3-21 characters, start with a letter, and contain only lowercase letters, numbers, or hyphens."
  }
}

### VPC

variable "vpc_region" {
  description = "IBM Cloud region where the VPC will be created (e.g., \"eu-es\")."
  type        = string
  default     = "eu-es"

  validation {
    condition     = length(trimspace(var.vpc_region)) > 0
    error_message = "vpc_region cannot be empty."
  }
}

variable "vpc_zone" {
  description = "Availability zone within the region for zonal VPC resources (e.g., \"eu-es-2\")."
  type        = string
  default     = "eu-es-2"

  validation {
    condition     = length(trimspace(var.vpc_zone)) > 0
    error_message = "vpc_zone cannot be empty."
  }
}

variable "ssh_file_public_key" {
  description = <<-EOT
    Path to the SSH public key to upload into your VSI (e.g., file("~/.ssh/id_rsa.pub")).
    Must be RSA format (2048 or 4096 bits).
  EOT
  type    = string
  default = "~/.ssh/id_rsa.pub"

  validation {
    condition     = can(regex("^ssh-rsa [A-Za-z0-9+/=]+(?: .*)?$", trimspace(
      file(var.ssh_file_public_key)
    )))
    error_message = "ssh_file_public_key must point to a valid RSA public key file in OpenSSH format."
  }
}

variable "vpc_cidr_block" {
  description = "Primary IPv4 CIDR block for the VPC (e.g., \"10.0.0.0/24\")."
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr_block))
    error_message = "vpc_cidr_block must be a valid IPv4 CIDR (e.g., 10.0.0.0/24)."
  }
}

variable "deploy_vsi" {
  description = "Whether to deploy a test VSI in the VPC."
  type        = bool
  default     = true
}
