# terraform-powervs-landing-zone

A Terraform configuration to deploy a simple IBM PowerVS landing zone:

* **PowerVS workspace** with a Linux LPAR instance
* **VPC** landing zone with optional test VSI
* **Client-to-site VPN** using IBM Secrets Manager for certificates
* **Transit Gateway** linking VPC and PowerVS network

## Prerequisites

* Terraform 1.9+
* IBM Cloud CLI v3+ (`ibmcloud`) configured with an IAM API key
* SSH key pair for VSI access

## Quick Start

1. Clone the repo:

   ```bash
   git clone https://github.com/your-org/terraform-powervs-landing-zone.git
   cd terraform-powervs-landing-zone
   ```
2. Initialize Terraform:

   ```bash
   terraform init
   ```
3. Review and edit `variables.tf` (or create a `.tfvars` file) to set:

   * `prefix`, `vpc_region`, `vpc_zone`
   * `resource_group`, `ibmcloud_api_key`
   * `ssh_file_public_key`, `vpc_cidr_block`, `deploy_vsi` (optional)
4. Plan & apply:

   ```bash
   terraform plan
   terraform apply
   ```
5. When done, destroy all resources:

   ```bash
   terraform destroy
   ```

## Modules

* **vpc**: Creates VPC, subnet, optional test VSI
* **network**: Sets up Secrets Manager, issues VPN certificates, and deploys client-to-site VPN
* **powervs**: Provisions PowerVS workspace, imports catalog image, and creates LPAR instance

## CIDR Choices

* **VPC CIDR (`var.vpc_cidr_block`)**: A /22 block (e.g. `10.10.0.0/22`) giving 1 024 IPs for your VPC.
* **Edge Subnet**: Uses the full VPC block so all 1 024 addresses live in one subnet.
* **PowerVS VLAN (`10.0.10.0/24`)**: A dedicated /24 network (256 IPs) for your PowerVS instances.
* **VPN Client Pool (`10.5.0.0/21`)**: A /21 range (2 048 IPs) reserved for VPN users, supporting up to \~2 000 concurrent clients.

## Outputs

* `powervs_workspace_crn`: CRN of the PowerVS workspace
* `powervs_image_name`: Name of the catalog image selected
* `powervs_catalog_images`: Map of all available images and the selected flag
* `delete_secrets_manager_command`: CLI commands to clean up trial SM instance

Feel free to customize variables and extend modules as needed.
