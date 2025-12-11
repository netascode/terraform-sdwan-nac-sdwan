resource "sdwan_policy_object_app_probe_class" "policy_object_app_probe_class" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.app_probe_classes, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    forwarding_class = each.value.forwarding_class
    map = [for m in try(each.value.mappings, []) : {
      color = m.color
      dscp  = try(m.dscp, null)
    }]
  }]
}
resource "sdwan_policy_object_application_list" "policy_object_application_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.application_lists, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in concat([for app in try(each.value.applications, []) : { "application" : app }], [for fam in try(each.value.application_families, []) : { "application_family" : fam }]) : {
    application        = try(e.application, null)
    application_family = try(e.application_family, null)
  }]
}

resource "sdwan_policy_object_as_path_list" "policy_object_as_path_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.as_path_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  as_path_list_id    = each.value.id
  entries = [for a in each.value.as_paths : {
    as_path_list = a
  }]
}

resource "sdwan_policy_object_class_map" "policy_object_class_map" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.forwarding_classes, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    queue = each.value.queue
  }]
}

resource "sdwan_policy_object_color_list" "policy_object_color_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.color_lists, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.colors, []) : {
    color = e
  }]
}

resource "sdwan_policy_object_data_ipv4_prefix_list" "policy_object_data_ipv4_prefix_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.ipv4_data_prefix_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.prefixes, []) : {
    ipv4_address       = split("/", e)[0]
    ipv4_prefix_length = split("/", e)[1]
  }]
}

resource "sdwan_policy_object_data_ipv6_prefix_list" "policy_object_data_ipv6_prefix_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.ipv6_data_prefix_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.prefixes, []) : {
    ipv6_address       = split("/", e)[0]
    ipv6_prefix_length = split("/", e)[1]
  }]
}

resource "sdwan_policy_object_expanded_community_list" "policy_object_expanded_community_list" {
  for_each                 = { for p in try(local.feature_profiles.policy_object_profile.expanded_community_lists, {}) : p.name => p }
  name                     = each.value.name
  description              = try(each.value.description, null)
  feature_profile_id       = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  expanded_community_lists = each.value.expanded_communities
}

resource "sdwan_policy_object_extended_community_list" "policy_object_extended_community_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.extended_community_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.extended_communities, []) : {
    extended_community = e
  }]
}

resource "sdwan_policy_object_ipv4_prefix_list" "policy_object_ipv4_prefix_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.ipv4_prefix_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.entries, []) : {
    ipv4_address       = split("/", e.prefix)[0]
    ipv4_prefix_length = split("/", e.prefix)[1]
    le                 = try(e.le, null)
    ge                 = try(e.ge, null)
  }]
}

resource "sdwan_policy_object_ipv6_prefix_list" "policy_object_ipv6_prefix_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.ipv6_prefix_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.entries, []) : {
    ipv6_address       = split("/", e.prefix)[0]
    ipv6_prefix_length = split("/", e.prefix)[1]
    le                 = try(e.le, null)
    ge                 = try(e.ge, null)
  }]
}

resource "sdwan_policy_object_mirror" "policy_object_mirror" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.mirrors, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    remote_destination_ip = each.value.remote_destination_ip
    source_ip             = each.value.source_ip
  }]
}

resource "sdwan_policy_object_policer" "policy_object_policer" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.policers, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    burst_bytes   = each.value.burst_bytes
    exceed_action = each.value.exceed_action
    rate_bps      = each.value.rate_bps
  }]
}

resource "sdwan_policy_object_security_data_ipv4_prefix_list" "policy_object_security_data_ipv4_prefix_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_data_ipv4_prefix_lists, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.prefixes, []) : {
    ip_prefix          = try(e, null)
    ip_prefix_variable = null # not supported in the UI
  }]
}

resource "sdwan_policy_object_security_fqdn_list" "policy_object_security_fqdn_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_fqdn_lists, {}) : p.name => p }
  name               = each.value.name
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.fqdns, []) : {
    pattern = try(e, null)
  }]
}

resource "sdwan_policy_object_security_ips_signature" "policy_object_security_ips_signature" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_ips_signature_lists, {}) : p.name => p }
  name               = each.value.name
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.entries, []) : {
    generator_id = try(e.generator_id, null)
    signature_id = try(e.signature_id, null)
  }]
}

resource "sdwan_policy_object_security_local_application_list" "policy_object_security_local_application_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_local_application_lists, {}) : p.name => p }
  name               = each.value.name
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in concat([for app in try(each.value.applications, []) : { "application" : app }], [for fam in try(each.value.application_families, []) : { "application_family" : fam }]) : {
    app        = try(e.application, null)
    app_family = try(e.application_family, null)
  }]
}

resource "sdwan_policy_object_sla_class_list" "policy_object_sla_class_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.sla_classes, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    app_probe_class_list_id               = try(sdwan_policy_object_app_probe_class.policy_object_app_probe_class[each.value.app_probe_class].id, null)
    jitter                                = try(each.value.jitter_ms, null)
    latency                               = try(each.value.latency_ms, null)
    loss                                  = try(each.value.loss_percentage, null)
    fallback_best_tunnel_criteria         = try(each.value.fallback_best_tunnel_criteria, null)
    fallback_best_tunnel_jitter_variance  = try(each.value.fallback_best_tunnel_jitter_variance, null)
    fallback_best_tunnel_latency_variance = try(each.value.fallback_best_tunnel_latency_variance, null)
    fallback_best_tunnel_loss_variance    = try(each.value.fallback_best_tunnel_loss_variance, null)
  }]
}

resource "sdwan_policy_object_standard_community_list" "policy_object_standard_community_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.standard_community_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.standard_communities, []) : {
    standard_community = e == "local-as" ? "local-AS" : e
  }]
}

resource "sdwan_policy_object_tloc_list" "policy_object_tloc_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.tloc_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.tlocs, []) : {
    color         = e.color
    encapsulation = e.encapsulation
    tloc_ip       = e.tloc_ip
    preference    = try(e.preference, null)
  }]
}

resource "sdwan_policy_object_preferred_color_group" "policy_object_preferred_color_group" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.preferred_color_groups, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    primary_color_preference   = each.value.primary_colors
    primary_path_preference    = try(each.value.primary_path_preference, null)
    secondary_color_preference = try(each.value.secondary_colors, null)
    secondary_path_preference  = try(each.value.secondary_path_preference, null)
    tertiary_color_preference  = try(each.value.tertiary_colors, null)
    tertiary_path_preference   = try(each.value.tertiary_path_preference, null)
  }]
}

resource "sdwan_policy_object_security_port_list" "policy_object_security_port_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_port_lists, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for port_value in try(each.value.ports, []) : {
    port = port_value
  }]
}

resource "sdwan_policy_object_security_protocol_list" "policy_object_security_protocol_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.security_protocol_lists, {}) : p.name => p }
  name               = each.value.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for protocol in try(each.value.protocols, []) : {
    protocol_name = protocol
  }]
}