output "default_values" {
  description = "All default values."
  value       = local.defaults
}

output "model" {
  description = "Full model."
  value       = local.model
}

output "ownership" {
  description = "What this state manages: manage_global, its local_set, the site IDs whose routers its device resources hold, and the groups, feature profiles and policy objects its entry claims."
  value = {
    manage_global        = local.manage_global
    local_set            = var.local_set
    sites                = sort(local.device_site_ids)
    configuration_groups = sort([for name, owner in local.configuration_group_owner : name if owner != "" && owner == local.local_set_key])
    policy_groups        = sort([for name, owner in local.policy_group_owner : name if owner != "" && owner == local.local_set_key])
    feature_profiles     = sort([for id, owner in local.profile_owner : id if owner == local.local_set_key])
    policy_objects       = sort(local.owned_local_policy_objects)
  }
  precondition {
    condition     = var.local_set == null || contains(keys(local.local_definitions), local.local_set_key)
    error_message = "local_set ${local.local_set_key} is not an entry of ownership.local_definitions."
  }
  precondition {
    condition     = var.local_set == null || !local.manage_global
    error_message = "local_set is for a site/region state: set manage_global = false."
  }
  precondition {
    condition     = length(local.ownership_bad_modes) == 0
    error_message = "ownership entries with an invalid feature_profiles or policy_objects (a list of names, exclusive or none): ${join(", ", local.ownership_bad_modes)}."
  }
  precondition {
    condition     = length(local.ownership_unknown_sites) == 0
    error_message = "ownership lists sites that are not in the data: ${join(", ", distinct(local.ownership_unknown_sites))}."
  }
  precondition {
    condition     = length(local.ownership_bad_sites) == 0
    error_message = "ownership sites must be site IDs or from-to ranges with from <= to: ${join(", ", local.ownership_bad_sites)}."
  }
  precondition {
    condition     = length(local.ownership_duplicate_sites) == 0
    error_message = "Sites in more than one ownership entry: ${join(", ", local.ownership_duplicate_sites)}."
  }
  precondition {
    condition     = length(local.ownership_unknown_items) == 0
    error_message = "ownership claims items that are not in the data (feature profiles: of a configuration or policy group type): ${join("; ", local.ownership_unknown_items)}."
  }
  precondition {
    condition     = length(local.ownership_duplicate_claims) == 0
    error_message = "Items claimed by more than one ownership entry: ${join("; ", local.ownership_duplicate_claims)}."
  }
  precondition {
    condition     = length(local.ownership_router_conflicts) == 0
    error_message = "Routers that more than one ownership entry selects (through sites, a claimed configuration group or a claimed policy group): ${join("; ", local.ownership_router_conflicts)}."
  }
  precondition {
    condition     = length(local.ownership_used_elsewhere) == 0
    error_message = "Claimed items used outside their entry (references only go from a site/region state to the global state; remove the claim): ${join("; ", local.ownership_used_elsewhere)}."
  }
  precondition {
    condition     = length(local.ownership_scope_refs) == 0
    error_message = "Scopes are global, so a group or profile a scope lists must be managed by the global state; remove the claim or the scope entry: ${join("; ", local.ownership_scope_refs)}."
  }
}
