variable "prefix" {
  description = <<-EOT
    A short, unique string prepended to the names of all resources in this deployment,  
    to avoid naming collisions.  
    Example: `"tf"`, `"demo-env"`.
  EOT
  type        = string
}

variable "vpc_region" {
  description = <<-EOT
    IBM Cloud region where the VPC and its sub-resources will be created.  
    Use the short region code, e.g. `"eu-de"` for Frankfurt or `"eu-es"` for Madrid.
  EOT
  type        = string
}

variable "vpc_zone" {
  description = <<-EOT
    Availability zone within the chosen region for zonal resources (subnets, VSIs, etc).  
    Must match one of the region’s zones, e.g. `"eu-de-3"` or `"eu-es-1"`.
  EOT
  type        = string
}

variable "ssh_file_public_key" {
  description = <<-EOT
    Path to an RSA SSH public key for your test VSI.  
    Key must be in OpenSSH format (2048 or 4096 bits) and should not already exist in the target region.  
    Example: `file("~/.ssh/id_rsa.pub")`
  EOT
  type        = string
}

variable "vpc_cidr_block" {
  description = <<-EOT
    A CIDR block to assign as the VPC’s private address space.  
    Must not overlap with existing networks.  
    Example: `"10.10.0.0/22"` (gives you 1024 addresses).
  EOT
  type        = string
}

variable "resource_group" {
  description = <<-EOT
    The ID of the IBM Cloud Resource Group under which all VPC and VSI resources will be provisioned.  
    List your groups with: `ibmcloud resource groups`.
  EOT
  type        = string
}

variable "deploy_vsi" {
  description = <<-EOT
    Boolean flag controlling whether a test VSI is created.  
    Set to `true` to deploy a single VSI for validation or `false` to skip it.
  EOT
  type        = bool
}

variable "tags" {
  description = <<-EOT
    A map of user-defined tags to apply to all resources in this module.  
    Keys and values must be strings.  
    E.g. { environment = "prod", project = "vpn-gateway" }
  EOT
  type        = map(string)
  default     = {}
}
