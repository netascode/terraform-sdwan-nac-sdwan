resource "sdwan_cli_feature_profile" "cli_feature_profile" {
  for_each    = { for t in try(local.feature_profiles.cli_profiles, {}) : t.name => t }
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
