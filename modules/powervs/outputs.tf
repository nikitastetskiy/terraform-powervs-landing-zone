output "powervs_workspace_crn" {
  description = "The Cloud Resource Name (CRN) of the PowerVS workspace."
  value       = ibm_pi_workspace.powervs_workspace.crn
}

output "powervs_workspace_id" {
  description = "The unique identifier of the PowerVS workspace (cloud_instance_id)."
  value       = ibm_pi_workspace.powervs_workspace.id
}

output "powervs_image_id" {
  description = "The image_id from the catalog that will be used for the instance."
  value       = local.selected_image
}

output "powervs_catalog_images" {
  description = "List of available PowerVS catalog images, with the selected one marked."
  value = [
    for img in data.ibm_pi_catalog_images.catalog_images.images :
    format("%s%s", img.name, img.image_id == local.selected_image ? " [selected]" : "")
  ]
}

output "powervs_instance_id" {
  description = "The ID of the provisioned PowerVS virtual server instance."
  value       = ibm_pi_instance.powervs_instance.id
}

output "powervs_instance_ip" {
  description = "The private IP address assigned to the PowerVS instance."
  value       = ibm_pi_instance.powervs_instance.pi_network[0].ip_address
}
