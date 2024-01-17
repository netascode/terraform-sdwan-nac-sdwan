locals {
  cedge_feature_templates = try(local.model.sdwan.cedge_feature_templates, {})
  edge_device_templates   = try(local.model.sdwan.edge_device_templates, {})
  localized_policies      = try(local.model.sdwan.localized_policies, {})
  policy_objects          = try(local.model.sdwan.policy_objects, {})
  sites                   = try(local.model.sdwan.sites, {})
  centralized_policies    = try(local.model.sdwan.centralized_policies, {})
  device_type_map = {
    "C8000V" : "vedge-C8000V"
    "C8300-1N1S-4T2X" : "vedge-C8300-1N1S-4T2X"
    "C8300-1N1S-6T" : "vedge-C8300-1N1S-6T"
    "C8300-2N2S-6T" : "vedge-C8300-2N2S-6T"
    "C8300-2N2S-4T2X" : "vedge-C8300-2N2S-4T2X"
    "C8500-12X4QC" : "vedge-C8500-12X4QC"
    "C8500-12X" : "vedge-C8500-12X"
    "C8500-20X6C" : "vedge-C8500-20X6C"
    "C8500L-8S4X" : "vedge-C8500L-8S4X"
    "C8200-1N-4T" : "vedge-C8200-1N-4T"
    "C8200L-1N-4T" : "vedge-C8200L-1N-4T"
  }
}
