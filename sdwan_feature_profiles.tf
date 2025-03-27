resource "sdwan_cli_feature_profile" "cli_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.cli_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_other_feature_profile" "other_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.other_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_service_feature_profile" "service_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.service_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_system_feature_profile" "system_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.system_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_transport_feature_profile" "transport_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.transport_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_policy_object_feature_profile" "policy_object_feature_profile" {
  count       = contains(keys(local.feature_profiles), "policy_object_profile") ? 1 : 0
  name        = try(local.feature_profiles.policy_object_profile.name, local.defaults.sdwan.feature_profiles.policy_object_profile.name)
  description = try(local.feature_profiles.policy_object_profile.description, "")
}
