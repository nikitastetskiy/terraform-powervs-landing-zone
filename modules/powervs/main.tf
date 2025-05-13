######################
# PowerVS
######################

resource "ibm_pi_workspace" "powervs_workspace" {
  pi_name               = "${var.prefix}-pvs-ws"
  pi_resource_group_id  = var.resource_group
  pi_datacenter         = var.powervs_zone
}

resource "ibm_pi_key" "powervs_ssh_key" {
  pi_key_name          = "${var.prefix}-ssh-key-pvs"
  pi_ssh_key           = file("~/.ssh/id_rsa.pub")
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}

resource "ibm_pi_network" "powervs_private_network" { # DNS de VPC es (161.26.0.7 y 161.26.0.8)
  pi_network_name      = "${var.prefix}-pvs-private-network"
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
  pi_network_type      = "vlan"
  pi_cidr              = "10.0.10.0/24"
  pi_gateway           = "10.0.10.1"
  pi_ipaddress_range {
    pi_starting_ip_address  = "10.0.10.2"
    pi_ending_ip_address    = "10.0.10.254"
  }
}

resource "ibm_pi_instance" "powervs_instance" {
  pi_instance_name      = "${var.prefix}-pvs"
  pi_memory             = "16"
  pi_processors         = "1"
  pi_proc_type          = "shared"
  pi_image_id           = local.selected_image
  pi_key_pair_name      = ibm_pi_key.powervs_ssh_key.name
  pi_sys_type           = "s1022"
  pi_storage_type = "tier0"
  pi_cloud_instance_id  = ibm_pi_workspace.powervs_workspace.id
  pi_health_status         = "OK"
  pi_storage_pool_affinity = false

  pi_network {
    network_id = ibm_pi_network.powervs_private_network.pi_network_name
    ip_address = "10.0.10.100"
  }

}

locals {
  selected_image = [for img in data.ibm_pi_catalog_images.catalog_images.images : img if img.name == "IBMi-75-05-2984-1"][0].image_id
}

data "ibm_pi_catalog_images" "catalog_images" {
  pi_cloud_instance_id = ibm_pi_workspace.powervs_workspace.id
}