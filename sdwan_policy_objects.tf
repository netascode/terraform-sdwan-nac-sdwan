resource "sdwan_policy_object_tloc_list" "policy_object_tloc_list" {
  for_each = { for p in try(local.feature_profiles.policy_object_profile.tloc_lists, {}) : p.name => p }
  name                = each.value.name
  description         = try(each.value.description, "")
  feature_profile_id  = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [for e in try(each.value.tlocs, []) : {
    color             = e.color
    encapsulation     = e.encapsulation
    tloc_ip           = e.tloc_ip
    preference        = try(e.preference, null)
  }]
}

resource "sdwan_policy_object_policer" "policy_object_policer" {
  for_each = { for p in try(local.feature_profiles.policy_object_profile.policers, {}) : p.name => p }
  name                = each.value.name
  description         = try(each.value.description, "")
  feature_profile_id  = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
  entries = [{
    burst_bytes       = each.value.burst_bytes
    exceed_action     = each.value.exceed_action
    rate_bps          = each.value.rate_bps
  }]
}