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
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.class_maps, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    queue = each.value.queue
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

resource "sdwan_policy_object_standard_community_list" "policy_object_standard_community_list" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.standard_community_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.standard_communities, []) : {
    standard_community = e
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
