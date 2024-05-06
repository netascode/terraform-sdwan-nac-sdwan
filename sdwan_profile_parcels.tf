resource "sdwan_cli_config_profile_parcel" "cli_config_profile_parcel" {
  for_each = {
    for cli in try(local.feature_profiles.cli_profiles, {}) :
    "${cli.name}-config" => cli
    if try(cli.config, null) != null
  }
  name               = try(each.value.config.name, "${each.value.name}-config")
  description        = try(each.value.config.description, "")
  feature_profile_id = sdwan_cli_feature_profile.cli_feature_profile[each.value.name].id
  cli_configuration  = each.value.config.cli_configuration
}
