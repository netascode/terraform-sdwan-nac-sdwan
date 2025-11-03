
resource "sdwan_policy_group" "policy_group" {
  for_each    = { for p in local.policy_groups : p.name => p }
  name        = each.value.name
  description = try(each.value.description, "")
  solution    = "sdwan"
  feature_profile_ids = flatten([
    try(sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id, []),
    try(each.value.application_priority, null) == null ? [] : [sdwan_application_priority_feature_profile.application_priority_feature_profile[each.value.application_priority].id],
  ])
  policy_versions = length(flatten([
    try(each.value.policy_object_profile, null) == null ? [] : local.policy_object_profile_features_versions,
    try(each.value.application_priority, null) == null ? [] : local.application_priority_policies_versions[each.value.application_priority]
    ])) == 0 ? null : flatten([
    try(each.value.policy_object_profile, null) == null ? [] : local.policy_object_profile_features_versions,
    try(each.value.application_priority, null) == null ? [] : local.application_priority_policies_versions[each.value.application_priority]
  ])
  devices = length([for router in local.routers : router if router.policy_group == each.value.name]) == 0 ? null : [
    for router in local.routers : {
      id     = router.chassis_id
      deploy = try(router.policy_group_deploy, local.defaults.sdwan.sites.routers.policy_group_deploy)
      variables = try(length(router.policy_variables) == 0, true) ? null : [for name, value in router.policy_variables : {
        name       = name
        value      = try(tostring(value), null)
        list_value = try(tolist(value), null)
      }]
    } if router.policy_group == each.value.name
  ]
  depends_on = [
    sdwan_tag.tag,
    sdwan_configuration_group.configuration_group,
  ]
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  application_priority_policies_versions = {
    for profile in try(local.feature_profiles.application_priority_profiles, []) : profile.name => flatten([
      try(profile.qos_policies, null) == null ? [] : [for policy in try(profile.qos_policies, []) : [
        sdwan_application_priority_qos_policy.application_priority_qos_policy["${profile.name}-${policy.name}"].version,
      ]],
    ])
  }
}
