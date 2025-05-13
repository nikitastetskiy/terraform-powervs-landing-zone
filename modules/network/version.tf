terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.76.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }
  }
}
