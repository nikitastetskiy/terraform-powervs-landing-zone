variable "prefix" {
  description = <<-EOT
    A short, unique string prepended to the names of all resources.  
    Example: "tf"
  EOT
  type        = string
}

variable "powervs_zone" {
  description = <<-EOT
    IBM PowerVS datacenter zone where resources will be created.  
    For Madrid Zone 4, use "mad04".
  EOT
  type        = string
  default     = "mad04"
}

variable "resource_group" {
  description = <<-EOT
    The ID of the IBM Cloud Resource Group to provision PowerVS resources into.  
    You can list your groups with:  
      ibmcloud resource groups
  EOT
  type        = string
}

variable "ibmcloud_api_key" {
  description = <<-EOT
    Your IBM Cloud IAM API key, with permissions to create and manage PowerVS resources.  
    Keep this secret; do not commit it to version control.
  EOT
  type        = string
  sensitive   = true
}

variable "ssh_file_public_key" {
  description = <<-EOT
    The SSH public key (path or literal) to upload into PowerVS for instance access.  
    Must be an RSA key (2048 or 4096 bits).  
    Example usage:  
      ssh_file_public_key = file("./id_rsa.pub")
  EOT
  type        = string
}
