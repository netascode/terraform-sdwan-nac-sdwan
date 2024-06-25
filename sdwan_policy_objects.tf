resource "sdwan_application_list_policy_object" "application_list_policy_object" {
  for_each = { for p in try(local.policy_objects.application_lists, {}) : p.name => p }
  name     = each.value.name
  #  entries = [for e in try(each.value.entries, []) : {
  entries = [for e in concat([for app in try(each.value.applications, []) : { "application" : app }], [for fam in try(each.value.application_families, []) : { "application_family" : fam }]) : {
    application        = try(e.application, null)
    application_family = try(e.application_family, null)
  }]
}

resource "sdwan_as_path_list_policy_object" "as_path_list_policy_object" {
  for_each = { for p in try(local.policy_objects.as_path_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.as_paths, []) : {
    as_path = e
  }]
}

resource "sdwan_class_map_policy_object" "class_map_policy_object" {
  for_each = { for p in try(local.policy_objects.class_maps, {}) : p.name => p }
  name     = each.value.name
  queue    = each.value.queue
}

resource "sdwan_color_list_policy_object" "color_list_policy_object" {
  for_each = { for p in try(local.policy_objects.color_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.colors, []) : {
    color = e
  }]
}

resource "sdwan_standard_community_list_policy_object" "standard_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.standard_community_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.standard_communities, []) : {
    community = e
  }]
}

resource "sdwan_data_ipv4_prefix_list_policy_object" "data_ipv4_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.ipv4_data_prefix_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.prefixes, []) : {
    prefix = e
  }]
}

resource "sdwan_expanded_community_list_policy_object" "expanded_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.expanded_community_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.expanded_communities, []) : {
    community = e
  }]
}

resource "sdwan_extended_community_list_policy_object" "extended_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.extended_community_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.extended_communities, []) : {
    community = e
  }]
}

resource "sdwan_policer_policy_object" "policer_policy_object" {
  for_each      = { for p in try(local.policy_objects.policers, {}) : p.name => p }
  name          = each.value.name
  burst         = each.value.burst_bytes
  exceed_action = each.value.exceed_action
  rate          = each.value.rate_bps
}

resource "sdwan_ipv4_prefix_list_policy_object" "ipv4_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.ipv4_prefix_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    prefix = e.prefix
    ge     = try(e.ge, null)
    le     = try(e.le, null)
  }]
}

resource "sdwan_mirror_policy_object" "mirror_policy_object" {
  for_each              = { for p in try(local.policy_objects.mirror_lists, {}) : p.name => p }
  name                  = each.value.name
  remote_destination_ip = each.value.remote_destination_ip
  source_ip             = each.value.source_ip
}

resource "sdwan_site_list_policy_object" "site_list_policy_object" {
  for_each = { for p in try(local.policy_objects.site_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in concat(try(each.value.site_ids, []), [for r in try(each.value.site_id_ranges, []) : "${r.from}-${r.to}"]) : {
    site_id = e
  }]
}

resource "sdwan_sla_class_policy_object" "sla_class_policy_object" {
  for_each                      = { for p in try(local.policy_objects.sla_classes, {}) : p.name => p }
  app_probe_class_id            = try(sdwan_app_probe_class_policy_object.app_probe_class_policy_object[each.value.app_probe_class].id, null)
  app_probe_class_version       = try(sdwan_app_probe_class_policy_object.app_probe_class_policy_object[each.value.app_probe_class].version, null)
  name                          = each.value.name
  jitter                        = try(each.value.jitter_ms, null)
  latency                       = try(each.value.latency_ms, null)
  loss                          = try(each.value.loss_percentage, null)
  fallback_best_tunnel_criteria = try(each.value.fallback_best_tunnel_criteria, null)
  fallback_best_tunnel_jitter   = try(each.value.fallback_best_tunnel_jitter, null)
  fallback_best_tunnel_latency  = try(each.value.fallback_best_tunnel_latency, null)
  fallback_best_tunnel_loss     = try(each.value.fallback_best_tunnel_loss, null)
}

resource "sdwan_tloc_list_policy_object" "tloc_list_policy_object" {
  for_each = { for p in try(local.policy_objects.tloc_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.tlocs, []) : {
    color         = e.color
    encapsulation = e.encapsulation
    tloc_ip       = e.tloc_ip
    preference    = try(e.preference, null)
  }]
}

resource "sdwan_vpn_list_policy_object" "vpn_list_policy_object" {
  for_each = { for p in try(local.policy_objects.vpn_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in concat(try(each.value.vpn_ids, []), [for r in try(each.value.vpn_id_ranges, []) : "${r.from}-${r.to}"]) : {
    vpn_id = e
  }]
}

resource "sdwan_app_probe_class_policy_object" "app_probe_class_policy_object" {
  for_each         = { for p in try(local.policy_objects.app_probe_classes, {}) : p.name => p }
  name             = each.value.name
  forwarding_class = each.value.forwarding_class
  mappings = [for e in try(each.value.mappings, []) : {
    color = e.color
    dscp  = try(e.dscp, null)
  }]
}

resource "sdwan_data_ipv6_prefix_list_policy_object" "data_ipv6_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.ipv6_data_prefix_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.prefixes, []) : {
    prefix = e
  }]
}

resource "sdwan_ipv6_prefix_list_policy_object" "ipv6_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.ipv6_prefix_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    prefix = e.prefix
    ge     = try(e.ge, null)
    le     = try(e.le, null)
  }]
}

resource "sdwan_preferred_color_group_policy_object" "preferred_color_group_policy_object" {
  for_each                   = { for p in try(local.policy_objects.preferred_color_groups, {}) : p.name => p }
  name                       = each.value.name
  primary_color_preference   = join(" ", [for c in each.value.primary_colors : c])
  primary_path_preference    = try(each.value.primary_path, null)
  secondary_color_preference = join(" ", [for c in try(each.value.secondary_colors, []) : c])
  secondary_path_preference  = try(each.value.secondary_path, null)
  tertiary_color_preference  = join(" ", [for c in try(each.value.tertiary_colors, []) : c])
  tertiary_path_preference   = try(each.value.tertiary_path, null)
}

resource "sdwan_region_list_policy_object" "region_list_policy_object" {
  for_each = { for p in try(local.policy_objects.region_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in toset(concat(try(each.value.region_ids, []), [for r in try(each.value.region_id_ranges, []) : "${r.from}-${r.to}"])) : {
    region_id = e
  }]
}

resource "sdwan_local_application_list_policy_object" "local_application_list_policy_object" {
  for_each = { for p in try(local.policy_objects.local_application_lists, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in concat([for app in try(each.value.applications, []) : { "application" : app }], [for fam in try(each.value.application_families, []) : { "application_family" : fam }]) : {
    application        = try(e.application, null)
    application_family = try(e.application_family, null)
  }]
}
