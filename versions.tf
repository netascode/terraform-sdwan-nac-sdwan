terraform {
  required_version = ">= 1.8.0"

  required_providers {
    sdwan = {
      source  = "CiscoDevNet/sdwan"
      version = ">= 0.11.1"
    }
    utils = {
      source  = "netascode/utils"
      version = ">= 2.0.1, < 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.3.0"
    }
  }
}
