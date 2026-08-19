locals {
  active_topology_groups = [for g in try(local.topology_groups, []) : g if try(g.activate, false)]

  # ============================================================================
  # Topology - Custom Control Parcel + Referenced Object Version Tracking
  # ============================================================================

  topology_profile_referenced_objects = {
    for profile in try(local.feature_profiles.topology_profiles, []) : profile.name => {
      color_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) :
          try(seq.match_entries.color_list, null)
        ]
      ])))
      standard_community_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) :
          try(seq.match_entries.community_list, null)
        ]
      ])))
      expanded_community_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) :
          try(seq.match_entries.expanded_community_list, null)
        ]
      ])))
      tloc_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) : [
            try(seq.match_entries.tloc_list, null),
            try(seq.action_entries.tloc_list, null),
            try(seq.action_entries.service_tloc_list, null),
            try(seq.action_entries.service_chain_tloc_list, null),
          ]
        ]
      ])))
      ipv4_prefix_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) :
          try(seq.match_entries.ipv4_prefix_list, null)
        ]
      ])))
      ipv6_prefix_lists = distinct(compact(flatten([
        for custom_control in try(profile.custom_policies, []) : [
          for seq in try(custom_control.sequences, []) :
          try(seq.match_entries.ipv6_prefix_list, null)
        ]
      ])))
    }
  }

  topology_profile_object_versions = {
    for profile in try(local.feature_profiles.topology_profiles, []) : profile.name => compact(flatten([
      [for n in try(local.topology_profile_referenced_objects[profile.name].color_lists, []) :
        try(sdwan_policy_object_color_list.policy_object_color_list[n].version, null)
      ],
      [for n in try(local.topology_profile_referenced_objects[profile.name].standard_community_lists, []) :
        try(sdwan_policy_object_standard_community_list.policy_object_standard_community_list[n].version, null)
      ],
      [for n in try(local.topology_profile_referenced_objects[profile.name].expanded_community_lists, []) :
        try(sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list[n].version, null)
      ],
      [for n in try(local.topology_profile_referenced_objects[profile.name].tloc_lists, []) :
        try(sdwan_policy_object_tloc_list.policy_object_tloc_list[n].version, null)
      ],
      [for n in try(local.topology_profile_referenced_objects[profile.name].ipv4_prefix_lists, []) :
        try(sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[n].version, null)
      ],
      [for n in try(local.topology_profile_referenced_objects[profile.name].ipv6_prefix_lists, []) :
        try(sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list[n].version, null)
      ],
    ]))
  }

  topology_profile_features_versions = {
    for profile in try(local.feature_profiles.topology_profiles, []) : profile.name => sort(flatten([
      try(profile.custom_policies, null) == null ? [] : [
        for custom_control in try(profile.custom_policies, []) :
        sdwan_topology_custom_control_feature.topology_custom_control_feature["${profile.name}-${custom_control.name}"].version
      ],
      try(profile.hub_spoke_policies, null) == null ? [] : [
        for hub_spoke in try(profile.hub_spoke_policies, []) :
        sdwan_topology_hub_spoke_feature.topology_hub_spoke_feature["${profile.name}-${hub_spoke.name}"].version
      ],
      try(profile.mesh_policies, null) == null ? [] : [
        for mesh in try(profile.mesh_policies, []) :
        sdwan_topology_mesh_feature.topology_mesh_feature["${profile.name}-${mesh.name}"].version
      ],
      try(local.topology_profile_object_versions[profile.name], []),
    ]))
  }
}

resource "sdwan_activate_topology_group" "activate_topology_group" {
  for_each         = { for g in local.active_topology_groups : g.name => g }
  id               = sdwan_topology_group.topology_group[each.value.name].id
  feature_versions = sdwan_topology_group.topology_group[each.value.name].feature_versions
  depends_on       = [sdwan_policy_group.policy_group]
  lifecycle {
    precondition {
      condition     = length(local.active_topology_groups) <= 1
      error_message = "Only one topology group can be active at a time. Set `activate: true` on at most one entry in `topology_groups`."
    }
  }
}

resource "sdwan_topology_group" "topology_group" {
  for_each    = { for g in try(local.topology_groups, []) : g.name => g }
  name        = each.value.name
  description = try(each.value.description, "")
  solution    = "sdwan"
  feature_profile_ids = flatten([
    sdwan_topology_feature_profile.topology_feature_profile[each.value.topology_profile].id,
    try(sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id, []),
  ])
  feature_versions = length(try(local.topology_profile_features_versions[each.value.topology_profile], [])) == 0 ? null : try(local.topology_profile_features_versions[each.value.topology_profile], null)
  lifecycle {
    create_before_destroy = true
  }
}
