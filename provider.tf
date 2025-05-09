provider "ibm" {
  region           = var.vpc_region # VPC Region
  zone             = var.vpc_zone # Zone should be eu-es-1 and eu-es-2
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "ibm" {
  alias            = "powervs"
  region           = "mad"   # PowerVS Region
  zone             = "mad02" # Zone could be mad02 and mad04
  ibmcloud_api_key = var.ibmcloud_api_key
}
