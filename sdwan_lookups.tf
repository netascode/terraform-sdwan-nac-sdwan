# References to things this state doesn't manage (manage_global, ownership) are read from SD-WAN
# Manager by name. Each map below holds an ID per name: from the resource when this state manages
# it, otherwise from a data source. Data sources are only read for names that are referenced and not
# managed here, so a single state reads none of them. A name that exists in neither fails the plan.

locals {
  # Group attribute => feature profile type it references.
  configuration_group_profile_types = {
    cli_profile       = "cli_profiles"
    other_profile     = "other_profiles"
    service_profile   = "service_profiles"
    system_profile    = "system_profiles"
    transport_profile = "transport_profiles"
  }
  policy_group_profile_types = {
    application_priority = "application_priority_profiles"
    ngfw_security        = "ngfw_security_profiles"
    sse                  = "sse_profiles"
  }
  group_profile_refs = concat(
    flatten([for g in local.configuration_groups : [
      for key, type in local.configuration_group_profile_types : { type = type, name = g[key] } if try(g[key], null) != null
    ]]),
    flatten([for g in local.policy_groups : [
      for key, type in local.policy_group_profile_types : { type = type, name = g[key] } if try(g[key], null) != null
    ]]),
  )
  # Profile type => names the groups of this state use but this state doesn't manage.
  profile_lookups = {
    for type in distinct(concat(values(local.configuration_group_profile_types), values(local.policy_group_profile_types))) : type => toset([
      for ref in local.group_profile_refs : ref.name
      if ref.type == type && !contains([for p in try(local.feature_profiles[type], []) : p.name], ref.name)
    ])
  }
}

data "sdwan_cli_feature_profile" "lookup" {
  for_each = local.profile_lookups.cli_profiles
  name     = each.key
}

data "sdwan_other_feature_profile" "lookup" {
  for_each = local.profile_lookups.other_profiles
  name     = each.key
}

data "sdwan_service_feature_profile" "lookup" {
  for_each = local.profile_lookups.service_profiles
  name     = each.key
}

data "sdwan_system_feature_profile" "lookup" {
  for_each = local.profile_lookups.system_profiles
  name     = each.key
}

data "sdwan_transport_feature_profile" "lookup" {
  for_each = local.profile_lookups.transport_profiles
  name     = each.key
}

data "sdwan_application_priority_feature_profile" "lookup" {
  for_each = local.profile_lookups.application_priority_profiles
  name     = each.key
}

data "sdwan_embedded_security_feature_profile" "lookup" {
  for_each = local.profile_lookups.ngfw_security_profiles
  name     = each.key
}

data "sdwan_sse_feature_profile" "lookup" {
  for_each = local.profile_lookups.sse_profiles
  name     = each.key
}

locals {
  profile_ids = {
    cli_profiles                  = merge({ for k, v in data.sdwan_cli_feature_profile.lookup : k => v.id }, { for k, v in sdwan_cli_feature_profile.cli_feature_profile : k => v.id })
    other_profiles                = merge({ for k, v in data.sdwan_other_feature_profile.lookup : k => v.id }, { for k, v in sdwan_other_feature_profile.other_feature_profile : k => v.id })
    service_profiles              = merge({ for k, v in data.sdwan_service_feature_profile.lookup : k => v.id }, { for k, v in sdwan_service_feature_profile.service_feature_profile : k => v.id })
    system_profiles               = merge({ for k, v in data.sdwan_system_feature_profile.lookup : k => v.id }, { for k, v in sdwan_system_feature_profile.system_feature_profile : k => v.id })
    transport_profiles            = merge({ for k, v in data.sdwan_transport_feature_profile.lookup : k => v.id }, { for k, v in sdwan_transport_feature_profile.transport_feature_profile : k => v.id })
    application_priority_profiles = merge({ for k, v in data.sdwan_application_priority_feature_profile.lookup : k => v.id }, { for k, v in sdwan_application_priority_feature_profile.application_priority_feature_profile : k => v.id })
    ngfw_security_profiles        = merge({ for k, v in data.sdwan_embedded_security_feature_profile.lookup : k => v.id }, { for k, v in sdwan_embedded_security_feature_profile.embedded_security_feature_profile : k => v.id })
    sse_profiles                  = merge({ for k, v in data.sdwan_sse_feature_profile.lookup : k => v.id }, { for k, v in sdwan_sse_feature_profile.sse_feature_profile : k => v.id })
  }

  # Groups the device resources of this state use (device_routers) but this state doesn't manage.
  configuration_group_lookups = toset([
    for router in local.device_routers : router.configuration_group
    if router.configuration_group != null && !contains([for g in local.configuration_groups : g.name], router.configuration_group)
  ])
  policy_group_lookups = toset([
    for router in local.device_routers : router.policy_group
    if router.policy_group != null && !contains([for g in local.policy_groups : g.name], router.policy_group)
  ])
}

data "sdwan_configuration_group" "lookup" {
  for_each = local.configuration_group_lookups
  name     = each.key
}

data "sdwan_policy_group" "lookup" {
  for_each = local.policy_group_lookups
  name     = each.key
}

locals {
  configuration_group_ids = merge({ for k, v in data.sdwan_configuration_group.lookup : k => v.id }, { for k, v in sdwan_configuration_group.configuration_group : k => v.id })
  policy_group_ids        = merge({ for k, v in data.sdwan_policy_group.lookup : k => v.id }, { for k, v in sdwan_policy_group.policy_group : k => v.id })
}

# The policy object profile is the tenant's single one, managed by the global state; other states
# that use it read it by name.
locals {
  policy_object_profile_in_data = contains(keys(local.model_feature_profiles), "policy_object_profile")
  policy_object_profile_name    = try(local.model_feature_profiles.policy_object_profile.name, local.defaults.sdwan.feature_profiles.policy_object_profile.name)
  policy_object_profile_lookup  = local.policy_object_profile_in_data && !local.manage_global && local.owns_local_definitions
}

data "sdwan_policy_object_feature_profile" "lookup" {
  count = local.policy_object_profile_lookup ? 1 : 0
  name  = local.policy_object_profile_name
}

locals {
  policy_object_profile_id = try(sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id, data.sdwan_policy_object_feature_profile.lookup[0].id, null)

  # Policy objects: a state whose own profiles use objects it doesn't manage reads the parcels of the
  # policy object profile in one call, and matches them by type and name. A state whose profiles use
  # only its own objects, or no objects, reads none.
  policy_object_lookup = local.policy_object_profile_in_data && length(local.policy_object_lookup_names) > 0
  policy_object_parcel_types = {
    app_probe_class                     = "app-probe"
    application_list                    = "app-list"
    as_path_list                        = "as-path"
    class_map                           = "class"
    color_list                          = "color"
    data_ipv4_prefix_list               = "data-prefix"
    data_ipv6_prefix_list               = "data-ipv6-prefix"
    expanded_community_list             = "expanded-community"
    extended_community_list             = "ext-community"
    ipv4_prefix_list                    = "prefix"
    ipv6_prefix_list                    = "ipv6-prefix"
    mirror                              = "mirror"
    policer                             = "policer"
    preferred_color_group               = "preferred-color-group"
    security_data_ipv4_prefix_list      = "security-data-ip-prefix"
    security_data_ipv6_prefix_list      = "security-data-ipv6-prefix"
    security_fqdn_list                  = "security-fqdn"
    security_geolocation_list           = "security-geolocation"
    security_ips_signature              = "security-ipssignature"
    security_local_application_list     = "security-localapp"
    security_local_domain_list          = "security-localdomain"
    security_object_group               = "security-object-group"
    security_rule_set                   = "security-rule-set"
    security_port_list                  = "security-port"
    security_protocol_list              = "security-protocolname"
    security_url_allow_list             = "security-urllist"
    security_url_block_list             = "security-urllist"
    security_zone                       = "security-zone"
    unified_url_filtering               = "url-filtering"
    sla_class_list                      = "sla-class"
    standard_community_list             = "standard-community"
    tloc_list                           = "tloc"
    unified_advanced_inspection_profile = "advanced-inspection-profile"
    unified_advanced_malware_protection = "advanced-malware-protection"
    unified_intrusion_prevention        = "intrusion-prevention"
  }
  policy_object_resource_ids = {
    app_probe_class                     = { for name, object in sdwan_policy_object_app_probe_class.policy_object_app_probe_class : name => object.id }
    application_list                    = { for name, object in sdwan_policy_object_application_list.policy_object_application_list : name => object.id }
    as_path_list                        = { for name, object in sdwan_policy_object_as_path_list.policy_object_as_path_list : name => object.id }
    class_map                           = { for name, object in sdwan_policy_object_class_map.policy_object_class_map : name => object.id }
    color_list                          = { for name, object in sdwan_policy_object_color_list.policy_object_color_list : name => object.id }
    data_ipv4_prefix_list               = { for name, object in sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list : name => object.id }
    data_ipv6_prefix_list               = { for name, object in sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list : name => object.id }
    expanded_community_list             = { for name, object in sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list : name => object.id }
    extended_community_list             = { for name, object in sdwan_policy_object_extended_community_list.policy_object_extended_community_list : name => object.id }
    ipv4_prefix_list                    = { for name, object in sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list : name => object.id }
    ipv6_prefix_list                    = { for name, object in sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list : name => object.id }
    mirror                              = { for name, object in sdwan_policy_object_mirror.policy_object_mirror : name => object.id }
    policer                             = { for name, object in sdwan_policy_object_policer.policy_object_policer : name => object.id }
    preferred_color_group               = { for name, object in sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group : name => object.id }
    security_data_ipv4_prefix_list      = { for name, object in sdwan_policy_object_security_data_ipv4_prefix_list.policy_object_security_data_ipv4_prefix_list : name => object.id }
    security_data_ipv6_prefix_list      = { for name, object in sdwan_policy_object_security_data_ipv6_prefix_list.policy_object_security_data_ipv6_prefix_list : name => object.id }
    security_fqdn_list                  = { for name, object in sdwan_policy_object_security_fqdn_list.policy_object_security_fqdn_list : name => object.id }
    security_geolocation_list           = { for name, object in sdwan_policy_object_security_geolocation_list.policy_object_security_geolocation_list : name => object.id }
    security_ips_signature              = { for name, object in sdwan_policy_object_security_ips_signature.policy_object_security_ips_signature : name => object.id }
    security_local_application_list     = { for name, object in sdwan_policy_object_security_local_application_list.policy_object_security_local_application_list : name => object.id }
    security_local_domain_list          = { for name, object in sdwan_policy_object_security_local_domain_list.policy_object_security_local_domain_list : name => object.id }
    security_object_group               = { for name, object in sdwan_policy_object_security_object_group.policy_object_security_object_group : name => object.id }
    security_rule_set                   = { for name, object in sdwan_policy_object_security_rule_set.policy_object_security_rule_set : name => object.id }
    security_port_list                  = { for name, object in sdwan_policy_object_security_port_list.policy_object_security_port_list : name => object.id }
    security_protocol_list              = { for name, object in sdwan_policy_object_security_protocol_list.policy_object_security_protocol_list : name => object.id }
    security_url_allow_list             = { for name, object in sdwan_policy_object_security_url_allow_list.policy_object_security_url_allow_list : name => object.id }
    security_url_block_list             = { for name, object in sdwan_policy_object_security_url_block_list.policy_object_security_url_block_list : name => object.id }
    security_zone                       = { for name, object in sdwan_policy_object_security_zone.policy_object_security_zone : name => object.id }
    unified_url_filtering               = { for name, object in sdwan_policy_object_unified_url_filtering.policy_object_unified_url_filtering : name => object.id }
    sla_class_list                      = { for name, object in sdwan_policy_object_sla_class_list.policy_object_sla_class_list : name => object.id }
    standard_community_list             = { for name, object in sdwan_policy_object_standard_community_list.policy_object_standard_community_list : name => object.id }
    tloc_list                           = { for name, object in sdwan_policy_object_tloc_list.policy_object_tloc_list : name => object.id }
    unified_advanced_inspection_profile = { for name, object in sdwan_policy_object_unified_advanced_inspection_profile.policy_object_unified_advanced_inspection_profile : name => object.id }
    unified_advanced_malware_protection = { for name, object in sdwan_policy_object_unified_advanced_malware_protection.policy_object_unified_advanced_malware_protection : name => object.id }
    unified_intrusion_prevention        = { for name, object in sdwan_policy_object_unified_intrusion_prevention.policy_object_unified_intrusion_prevention : name => object.id }
  }
  policy_object_lookup_parcels = try(data.sdwan_policy_object_feature_profile_parcels.lookup[0].parcels, [])
  policy_object_ids = {
    for type, parcel_type in local.policy_object_parcel_types : type => merge(
      { for p in local.policy_object_lookup_parcels : p.parcel_name => p.parcel_id if p.parcel_type == parcel_type },
      local.policy_object_resource_ids[type],
    )
  }

  # Forwarding class queues, read from the data so that a state without the objects has them too.
  forwarding_class_queues = { for c in try(local.model_feature_profiles.policy_object_profile.forwarding_classes, []) : c.name => tostring(c.queue) }
}

data "sdwan_policy_object_feature_profile_parcels" "lookup" {
  count              = local.policy_object_lookup ? 1 : 0
  feature_profile_id = local.policy_object_profile_id
}
