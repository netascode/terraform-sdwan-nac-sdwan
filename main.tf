locals {
  # Each block is emptied when this state doesn't manage it (manage_global, ownership, sdwan_ownership.tf).
  application_catalog    = { for k, v in try(local.model.sdwan.application_catalog, {}) : k => v if local.manage_global }
  edge_feature_templates = { for k, v in try(local.model.sdwan.edge_feature_templates, {}) : k => v if local.manage_global }
  edge_device_templates  = [for t in try(local.model.sdwan.edge_device_templates, []) : t if local.manage_global]
  localized_policies     = { for k, v in try(local.model.sdwan.localized_policies, {}) : k => v if local.manage_global }
  security_policies      = { for k, v in try(local.model.sdwan.security_policies, {}) : k => v if local.manage_global }
  policy_objects         = { for k, v in try(local.model.sdwan.policy_objects, {}) : k => v if local.manage_global }
  sites                  = try(local.model.sdwan.sites, [])
  centralized_policies   = { for k, v in try(local.model.sdwan.centralized_policies, {}) : k => v if local.manage_global }
  configuration_groups   = local.owned_configuration_groups
  feature_profiles       = local.owned_feature_profiles
  network_hierarchy      = { for k, v in try(local.model.sdwan.network_hierarchy, {}) : k => v if local.manage_global }
  policy_groups          = local.owned_policy_groups
  scopes                 = [for s in try(local.model.sdwan.scopes, []) : s if local.manage_global]
  settings               = { for k, v in try(local.model.sdwan.settings, {}) : k => v if local.manage_global }
  topology_groups        = [for g in try(local.model.sdwan.topology_groups, []) : g if local.manage_global]
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

check "handover_sites" {
  assert {
    condition     = alltrue([for id in var.handover_sites : contains([for site in try(local.sites, []) : site.id], id)])
    error_message = "handover_sites lists sites that are not in the data: ${join(", ", [for id in var.handover_sites : tostring(id) if !contains([for site in try(local.sites, []) : site.id], id)])}. Their routers are not handed over."
  }
}
