resource "sdwan_activate_topology_group" "activate_topology_group" {
  for_each = { for g in try(local.topology_groups, []) : "active" => g
  if try(g.activate, false) == true }
  id               = sdwan_topology_group.topology_group[each.value.name].id
  feature_versions = sdwan_topology_group.topology_group[each.value.name].feature_versions
  lifecycle {
    precondition {
      condition     = length([for g in try(local.topology_groups, []) : g if try(g.activate, false) == true]) <= 1
      error_message = "Only one topology group can be active at a time. Set `activate: true` on at most one entry in `topology_groups`."
    }
  }
}

resource "sdwan_topology_custom_control_feature" "topology_custom_control_feature" {
  for_each = {
    for custom_control_item in flatten([
      for profile in try(local.feature_profiles.topology_profiles, []) : [
        for custom_control in try(profile.custom_policies, []) : {
          profile        = profile
          custom_control = custom_control
        }
      ]
    ])
    : "${custom_control_item.profile.name}-${custom_control_item.custom_control.name}" => custom_control_item
  }
  name                  = each.value.custom_control.name
  description           = null # not supported in the UI
  feature_profile_id    = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  default_action        = try(each.value.custom_control.default_action, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.default_action)
  target_level          = lookup({ "sites" = "SITE", "wan_regions" = "REGION", "sub_regions" = "SUB_REGION" }, try(each.value.custom_control.target_level, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.target_level), null)
  target_vpn            = null # not supported in the UI
  target_role           = lookup({ "border" = "border-router", "edge" = "edge-router" }, try(each.value.custom_control.target_role, ""), null)
  target_inbound_sites  = try(each.value.custom_control.target_inbound_sites, null)
  target_outbound_sites = try(each.value.custom_control.target_outbound_sites, null)
  target_inbound_regions = try(length(each.value.custom_control.target_inbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.target_inbound_regions, []) : {
    region      = try(region.region, null)
    sub_regions = null # not supported in the UI
  }]
  target_outbound_regions = try(length(each.value.custom_control.target_outbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.target_outbound_regions, []) : {
    region      = try(region.region, null)
    sub_regions = null # not supported in the UI
  }]
  sequences = try(length(each.value.custom_control.sequences) == 0, true) ? null : [for seq in try(each.value.custom_control.sequences, []) : {
    # Transform user-friendly sequence IDs (1,2,3,4) to API sequence IDs (10,20,30,40)
    # Formula: (user_id) * 10
    id          = seq.sequence_id * 10
    name        = try(seq.sequence_name, "Rule${seq.sequence_id}")
    base_action = try(seq.base_action, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.base_action)
    type        = try(seq.type, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.type)
    ip_type     = lookup({ "both" = "all" }, try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol), try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol)) # try(seq.type, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.type) == "tloc" ? null : lookup({ "both" = "all" }, try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol), try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol))
    match_entries = try(seq.match_entries, null) == null ? null : flatten([
      try(seq.match_entries.color_list, null) != null ? [{
        color_list_id = sdwan_policy_object_color_list.policy_object_color_list[seq.match_entries.color_list].id
      }] : [],
      try(seq.match_entries.community_list, null) != null ? [{
        community_list_id = sdwan_policy_object_standard_community_list.policy_object_standard_community_list[seq.match_entries.community_list].id
      }] : [],
      try(seq.match_entries.expanded_community_list, null) != null ? [{
        expanded_community_list_id = sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list[seq.match_entries.expanded_community_list].id
      }] : [],
      try(seq.match_entries.omp_tag, null) != null ? [{
        omp_tag = seq.match_entries.omp_tag
      }] : [],
      try(seq.match_entries.origin, null) != null ? [{
        origin = seq.match_entries.origin
      }] : [],
      try(seq.match_entries.originator, null) != null ? [{
        originator = seq.match_entries.originator
      }] : [],
      try(seq.match_entries.preference, null) != null ? [{
        preference = seq.match_entries.preference
      }] : [],
      try(seq.match_entries.sites, null) != null ? [{
        site = seq.match_entries.sites
      }] : [],
      try(length(seq.match_entries.wan_regions), 0) > 0 ? [{
        match_regions = [for region in seq.match_entries.wan_regions : {
          region      = try(region.region, null)
          sub_regions = null # not supported in the UI
        }]
      }] : [],
      try(seq.match_entries.role, null) != null ? [{
        role = lookup({ "border" = "border-router", "edge" = "edge-router" }, try(seq.match_entries.role, ""), null)
      }] : [],
      try(seq.match_entries.path_type, null) != null ? [{
        path_type = seq.match_entries.path_type
      }] : [],
      try(seq.match_entries.tloc_list, null) != null ? [{
        tloc_list_id = sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.match_entries.tloc_list].id
      }] : [],
      try(seq.match_entries.lan_vpn_names, null) != null ? [{
        vpn = seq.match_entries.lan_vpn_names
      }] : [],
      try(seq.match_entries.ipv4_prefix_list, null) != null ? [{
        prefix_list_id = sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[seq.match_entries.ipv4_prefix_list].id
      }] : [],
      try(seq.match_entries.ipv6_prefix_list, null) != null ? [{
        ipv6_prefix_list_id = sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list[seq.match_entries.ipv6_prefix_list].id
      }] : [],
      try(seq.match_entries.carrier, null) != null ? [{
        carrier = seq.match_entries.carrier
      }] : [],
      try(seq.match_entries.domain_id, null) != null ? [{
        domain_id = seq.match_entries.domain_id
      }] : [],
      try(seq.match_entries.group_id, null) != null ? [{
        group_id = seq.match_entries.group_id
      }] : [],
      try(seq.match_entries.tloc_ip, null) != null ? [{
        tloc_ip            = seq.match_entries.tloc_ip
        tloc_color         = try(seq.match_entries.tloc_color, null)
        tloc_encapsulation = try(seq.match_entries.tloc_encapsulation, null)
      }] : [],
    ])
    action_entries = try(seq.action_entries, null) == null ? null : flatten([
      try(seq.action_entries.export_to_lan_vpn_names, null) != null ? [{
        export_to_vpn = seq.action_entries.export_to_lan_vpn_names
      }] : [],
      anytrue([
        try(seq.action_entries.preference, null) != null,
        try(seq.action_entries.omp_tag, null) != null,
        try(seq.action_entries.community, null) != null,
        try(seq.action_entries.community_additive, null) != null,
        try(seq.action_entries.affinity, null) != null,
        try(seq.action_entries.service_type, null) != null,
        try(seq.action_entries.service_chain_name, null) != null,
        try(seq.action_entries.tloc_action, null) != null,
        try(seq.action_entries.tloc_ip, null) != null,
        try(seq.action_entries.tloc_list, null) != null,
        ]) ? [{
        set_parameters = flatten([
          try(seq.action_entries.preference, null) != null ? [{
            preference = seq.action_entries.preference
          }] : [],
          try(seq.action_entries.omp_tag, null) != null ? [{
            omp_tag = seq.action_entries.omp_tag
          }] : [],
          try(seq.action_entries.community, null) != null ? [{
            community = seq.action_entries.community
          }] : [],
          try(seq.action_entries.community, null) != null ? [{
            community_additive = try(seq.action_entries.community_additive, null)
          }] : [],
          try(seq.action_entries.affinity, null) != null ? [{
            affinity = seq.action_entries.affinity
          }] : [],
          try(seq.action_entries.service_type, null) != null ? [{
            service_type               = seq.action_entries.service_type
            service_vpn                = try(seq.action_entries.service_vpn, null)
            service_tloc_ip            = try(seq.action_entries.service_tloc_ip, null)
            service_tloc_color         = try(seq.action_entries.service_tloc_color, null)
            service_tloc_encapsulation = try(seq.action_entries.service_tloc_encapsulation, null)
            service_tloc_list_id       = try(seq.action_entries.service_tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.service_tloc_list].id : null
          }] : [],
          try(seq.action_entries.service_chain_name, null) != null ? [{
            service_chain_type               = seq.action_entries.service_chain_name
            service_chain_vpn                = try(seq.action_entries.service_chain_vpn, null)
            service_chain_tloc_ip            = try(seq.action_entries.service_chain_tloc_ip, null)
            service_chain_tloc_color         = try(seq.action_entries.service_chain_tloc_color, null)
            service_chain_tloc_encapsulation = try(seq.action_entries.service_chain_tloc_encapsulation, null)
            service_chain_tloc_list_id       = try(seq.action_entries.service_chain_tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.service_chain_tloc_list].id : null
          }] : [],
          try(seq.action_entries.tloc_action, null) != null ? [{
            tloc_action = seq.action_entries.tloc_action
          }] : [],
          try(seq.action_entries.tloc_ip, null) != null ? [{
            tloc_ip            = seq.action_entries.tloc_ip
            tloc_color         = try(seq.action_entries.tloc_color, null)
            tloc_encapsulation = try(seq.action_entries.tloc_encapsulation, null)
          }] : [],
          try(seq.action_entries.tloc_list, null) != null ? [{
            tloc_list_id = sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.tloc_list].id
          }] : [],
        ])
      }] : [],
    ])
  }]
}

resource "sdwan_topology_group" "topology_group" { # change and see ; dependency vs versioning changes directly
  for_each    = { for g in try(local.topology_groups, []) : g.name => g }
  name        = each.value.topology_profile                                                                      #each.value.name
  description = sdwan_topology_feature_profile.topology_feature_profile[each.value.topology_profile].description #try(each.value.description, "")
  solution    = "sdwan"
  feature_profile_ids = flatten([
    sdwan_topology_feature_profile.topology_feature_profile[each.value.topology_profile].id,
    sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id,
  ])
  feature_versions = length(try(local.topology_profile_features_versions[each.value.topology_profile], [])) == 0 ? null : try(local.topology_profile_features_versions[each.value.topology_profile], null)
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # ============================================================================
  # Topology - Custom Control Parcel + Referenced Object Version Tracking
  # ============================================================================

  # Names of policy objects referenced inside custom-control sequences, per
  # topology profile. Names are de-duplicated (distinct) since versions are
  # looked up positionally afterwards.
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

  # Versions of the referenced policy objects, per topology profile.
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

  # Combined per-profile version list: custom-control parcel versions plus the
  # versions of every policy object they reference. Built from the data-model
  # list so removing a custom_policies entry drops its version element too.
  topology_profile_features_versions = {
    for profile in try(local.feature_profiles.topology_profiles, []) : profile.name => sort(flatten([
      try(profile.custom_policies, null) == null ? [] : [
        for custom_control in try(profile.custom_policies, []) :
        sdwan_topology_custom_control_feature.topology_custom_control_feature["${profile.name}-${custom_control.name}"].version
      ],
      try(local.topology_profile_object_versions[profile.name], []),
    ]))
  }
}
