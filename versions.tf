terraform {
  required_version = ">=1.3.0"

  required_providers {
    sdwan = {
      source  = "CiscoDevNet/sdwan"
      version = ">= 0.4.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 0.2.5"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}


