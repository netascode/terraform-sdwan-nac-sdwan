terraform {
  required_version = ">=1.3.0"

  required_providers {
    sdwan = {
      source  = "CiscoDevNet/sdwan"
      version = ">= 0.8.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 1.0.2, < 2.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}