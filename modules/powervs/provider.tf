provider "ibm" {
  region           = "mad"   # PowerVS Region
  zone             = "mad02" # Zone could be mad02 and mad04
  ibmcloud_api_key = var.ibmcloud_api_key
}
