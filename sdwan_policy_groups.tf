
resource "sdwan_policy_group" "policy_group" {
  for_each    = { for p in local.policy_groups : p.name => p }
  name        = each.value.name
  description = try(each.value.description, "")
  solution    = "sdwan"
  feature_profile_ids = flatten([
    try(sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id, []),
    try(each.value.application_priority, null) == null ? [] : [sdwan_application_priority_feature_profile.application_priority_feature_profile[each.value.application_priority].id],
  ])
  policy_versions = length(
    try(each.value.application_priority, null) == null ? [] : local.application_priority_policies_versions[each.value.application_priority]
  ) == 0 ? null : local.application_priority_policies_versions[each.value.application_priority]
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
  # ============================================================================
  # Application Priority - Policy Object Reference Tracking
  # ============================================================================

  application_priority_referenced_objects = {
    for profile in try(local.feature_profiles.application_priority_profiles, []) : profile.name => {

      # QoS Policy References
      qos_class_maps = distinct(compact(flatten([
        for qos_policy in try(profile.qos_policies, []) : [
          for scheduler in try(qos_policy.qos_schedulers, []) :
          try(scheduler.forwarding_class, null)
        ]
      ])))
      # Traffic Policy Match Criteria References
      application_lists = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) : [
            try(seq.match_entries.application_list, null),
            try(seq.match_entries.dns_application_list, null),
            try(seq.match_entries.saas_application_list, null),
          ]
        ]
      ])))
      data_ipv4_prefix_lists = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) : [
            try(seq.match_entries.destination_data_ipv4_prefix_list, null),
            try(seq.match_entries.source_data_ipv4_prefix_list, null),
          ]
        ]
      ])))
      data_ipv6_prefix_lists = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) : [
            try(seq.match_entries.destination_data_ipv6_prefix_list, null),
            try(seq.match_entries.source_data_ipv6_prefix_list, null),
          ]
        ]
      ])))
      sla_class_lists = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) :
          try(seq.actions.sla_class.sla_class_list, null)
        ]
      ])))
      preferred_color_groups = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) : [
            try(seq.actions.sla_class.preferred_color_group, null),
            try(seq.actions.preferred_color_group, null),
          ]
        ]
      ])))
      action_class_maps = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) :
          try(seq.actions.forwarding_class, null)
        ]
      ])))

      # Policers (used in set_parameters)
      policers = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) :
          try(seq.actions.policer_list, null)
        ]
      ])))
      tloc_lists = distinct(compact(flatten([
        for traffic_policy in try(profile.traffic_policies, []) : [
          for seq in try(traffic_policy.sequences, []) : [
            try(seq.actions.service.tloc_list, null),
            try(seq.actions.service_chain.tloc_list, null),
            try(seq.actions.tloc.list, null),
          ]
        ]
      ])))
    }
  }

  # ============================================================================
  # Application Priority - Referenced Object Versions
  # ============================================================================
  application_priority_object_versions = {
    for profile in try(local.feature_profiles.application_priority_profiles, []) : profile.name => compact(flatten([

      # QoS Class Maps (forwarding classes in QoS schedulers)
      [for cm in try(local.application_priority_referenced_objects[profile.name].qos_class_maps, []) :
        try(sdwan_policy_object_class_map.policy_object_class_map[cm].version, null)
      ],

      # Application Lists
      [for al in try(local.application_priority_referenced_objects[profile.name].application_lists, []) :
        try(sdwan_policy_object_application_list.policy_object_application_list[al].version, null)
      ],

      # IPv4 Data Prefix Lists
      [for pl in try(local.application_priority_referenced_objects[profile.name].data_ipv4_prefix_lists, []) :
        try(sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[pl].version, null)
      ],

      # IPv6 Data Prefix Lists
      [for pl in try(local.application_priority_referenced_objects[profile.name].data_ipv6_prefix_lists, []) :
        try(sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[pl].version, null)
      ],

      # SLA Class Lists
      [for sl in try(local.application_priority_referenced_objects[profile.name].sla_class_lists, []) :
        try(sdwan_policy_object_sla_class_list.policy_object_sla_class_list[sl].version, null)
      ],

      # Preferred Color Groups
      [for pg in try(local.application_priority_referenced_objects[profile.name].preferred_color_groups, []) :
        try(sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group[pg].version, null)
      ],

      # Action Class Maps (forwarding classes in set_parameters)
      [for cm in try(local.application_priority_referenced_objects[profile.name].action_class_maps, []) :
        try(sdwan_policy_object_class_map.policy_object_class_map[cm].version, null)
      ],

      # Policers
      [for p in try(local.application_priority_referenced_objects[profile.name].policers, []) :
        try(sdwan_policy_object_policer.policy_object_policer[p].version, null)
      ],

      # TLOC Lists
      [for tl in try(local.application_priority_referenced_objects[profile.name].tloc_lists, []) :
        try(sdwan_policy_object_tloc_list.policy_object_tloc_list[tl].version, null)
      ],
    ]))
  }

  # ============================================================================
  # Application Priority - Policy Versions (QoS and Traffic Policies)
  # ============================================================================

  application_priority_policy_versions = {
    for profile in try(local.feature_profiles.application_priority_profiles, []) : profile.name => flatten([
      try(profile.qos_policies, null) == null ? [] : [for policy in try(profile.qos_policies, []) :
        sdwan_application_priority_qos_policy.application_priority_qos_policy["${profile.name}-${policy.name}"].version
      ],
      try(profile.traffic_policies, null) == null ? [] : [for policy in try(profile.traffic_policies, []) :
        sdwan_application_priority_traffic_policy_policy.application_priority_traffic_policy["${profile.name}-${policy.name}"].version
      ],
    ])
  }

  # ============================================================================
  # Application Priority - Combined Policy and Object Versions
  # ============================================================================

  application_priority_policies_versions = {
    for profile in try(local.feature_profiles.application_priority_profiles, []) : profile.name => sort(flatten([

      # Policy versions (the policies themselves)
      try(local.application_priority_policy_versions[profile.name], []),

      # Referenced object versions
      try(local.application_priority_object_versions[profile.name], [])
    ]))
  }
}
