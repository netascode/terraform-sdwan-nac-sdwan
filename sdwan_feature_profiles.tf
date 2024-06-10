resource "sdwan_cli_feature_profile" "cli_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.cli_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}

resource "sdwan_system_feature_profile" "system_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.system_profiles, {}) : t.name => t }
  name        = each.value.name
  description = try(each.value.description, "")
}
