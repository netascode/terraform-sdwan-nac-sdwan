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