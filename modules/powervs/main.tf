######################
# PowerVS
######################

resource "ibm_pi_workspace" "powervs_workspace" { # Create a PowerVS workspace (logical container for assets like images, networks, instances)
  pi_name              = "${var.prefix}-pvs-workspace"
  pi_resource_group_id = var.resource_group
  pi_datacenter        = var.powervs_zone
}

######################
# SSH Key Import
######################

resource "ibm_pi_key" "powervs_ssh_key" { # Upload your SSH public key so instances can be accessed securely
  depends_on           = [ibm_pi_workspace.powervs_workspace]
  pi_key_name          = "${var.prefix}-ssh-key-pvs"
  pi_ssh_key           = file(var.ssh_file_public_key)
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}

######################
# Private VLAN Network
######################

resource "ibm_pi_network" "powervs_private_network" { # Tip: The DNS of the VPC in IBM Cloud is (161.26.0.7 and 161.26.0.8)
  depends_on           = [ibm_pi_workspace.powervs_workspace]
  pi_network_name      = "${var.prefix}-pvs-private-network"
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
  pi_network_type      = "vlan"
  pi_cidr              = "10.0.10.0/24"
  pi_gateway           = "10.0.10.1"
  pi_ipaddress_range {
    pi_starting_ip_address = "10.0.10.2"
    pi_ending_ip_address   = "10.0.10.254"
  }
}

################################
# Select & Import a Catalog Image
################################

data "ibm_pi_catalog_images" "catalog_images" { # Pull the list of public PowerVS images
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}

locals { # Choose the one you want by name (guarding for no-match)
  selected_image = [for img in data.ibm_pi_catalog_images.catalog_images.images : img if img.name == "IBMi-75-05-2984-1"][0].image_id
}

resource "ibm_pi_image" "ibm_i_image" { # Reference an existing catalog image (no actual import on destroy)
  depends_on           = [ibm_pi_workspace.powervs_workspace]
  pi_image_id          = local.selected_image
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}

##############################
# PowerVS Virtual Server Instance
##############################

resource "ibm_pi_instance" "powervs_instance" { # Launch the LPAR using the selected image & network
  pi_instance_name         = "${var.prefix}-lpar"
  pi_memory                = "8"
  pi_processors            = "0.25"
  pi_proc_type             = "shared"
  pi_image_id              = ibm_pi_image.ibm_i_image.image_id
  pi_key_pair_name         = ibm_pi_key.powervs_ssh_key.name
  pi_sys_type              = "s1022"
  pi_storage_type          = "tier3"
  pi_cloud_instance_id     = ibm_pi_workspace.powervs_workspace.id
  pi_health_status         = "OK"
  pi_storage_pool_affinity = false

  pi_network {
    network_id = ibm_pi_network.powervs_private_network.pi_network_name
    ip_address = "10.0.10.100"
  }
}
