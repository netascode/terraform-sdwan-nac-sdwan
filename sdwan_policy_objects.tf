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

resource "sdwan_policy_object_mirror" "policy_object_mirror" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.mirror_lists, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    remote_destination_ip = each.value.remote_destination_ip
    source_ip             = each.value.source_ip
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
    ge                 = try(e.g1, null)
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
    ge                 = try(e.g1, null)
  }]
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

resource "sdwan_policy_object_expanded_community_list" "policy_object_expanded_community_list" {
  for_each                 = { for p in try(local.feature_profiles.policy_object_profile.expanded_community_lists, {}) : p.name => p }
  name                     = each.value.name
  description              = try(each.value.description, null)
  feature_profile_id       = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  expanded_community_lists = each.value.expanded_communities
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

resource "sdwan_policy_object_class_map" "policy_object_class_map" {
  for_each           = { for p in try(local.feature_profiles.policy_object_profile.class_maps, {}) : p.name => p }
  name               = each.value.name
  description        = try(each.value.description, null)
  feature_profile_id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    queue = each.value.queue
  }]
}
