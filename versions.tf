terraform {
  required_version = ">= 1.8.0"

  required_providers {
    sdwan = {
      source = "CiscoDevNet/sdwan"
      # sig_security_profiles (sdwan_sig_security_sig_feature) needs the provider release that ships that resource
      # (0.11.8 or later); raise the floor here when it is published
      version = "~> 0.11.5"
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
