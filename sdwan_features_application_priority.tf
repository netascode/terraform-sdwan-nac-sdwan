resource "sdwan_application_priority_qos_policy" "application_priority_qos_policy" {
  for_each = {
    for qos_item in flatten([
      for profile in try(local.feature_profiles.application_priority_profiles, []) : [
        for qos_policy in try(profile.qos_policies, []) : {
          profile    = profile
          qos_policy = qos_policy
        }
      ]
    ])
    : "${qos_item.profile.name}-${qos_item.qos_policy.name}" => qos_item
  }
  name                      = each.value.qos_policy.name
  description               = null # not supported in the UI
  feature_profile_id        = sdwan_application_priority_feature_profile.application_priority_feature_profile[each.value.profile.name].id
  target_interface          = try(each.value.qos_policy.target_interfaces, null)
  target_interface_variable = try("{{${each.value.qos_policy.target_interfaces_variable}}}", null)
  qos_schedulers = try(length(each.value.qos_policy.qos_schedulers) == 0, true) ? null : [for s in each.value.qos_policy.qos_schedulers : {
    bandwidth           = s.bandwidth_percent
    drops               = s.drops
    forwarding_class_id = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].id
    queue               = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].entries[0].queue
    scheduling_type     = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].entries[0].queue == "0" ? "llq" : "wrr"
  }]
}
