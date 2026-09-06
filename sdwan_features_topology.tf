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
  target_level          = lookup({ "sites" = "SITE", "wan_regions" = "REGION" }, try(each.value.custom_control.level, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.level), null)
  target_vpn            = null # not supported in the UI
  target_role           = lookup({ "border" = "border-router", "edge" = "edge-router" }, try(each.value.custom_control.role, ""), null)
  target_inbound_sites  = try(each.value.custom_control.inbound_sites, null)
  target_outbound_sites = try(each.value.custom_control.outbound_sites, null)
  target_inbound_regions = try(length(each.value.custom_control.inbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.inbound_regions, []) : {
    region = region
  }]
  target_outbound_regions = try(length(each.value.custom_control.outbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.outbound_regions, []) : {
    region = region
  }]
  sequences = try(length(each.value.custom_control.sequences) == 0, true) ? null : [for seq in try(each.value.custom_control.sequences, []) : {
    # Transform user-friendly sequence IDs (1,2,3,4) to API sequence IDs (10,20,30,40)
    # Formula: (user_id) * 10
    id          = seq.sequence_id * 10
    name        = try(seq.sequence_name, "Rule${seq.sequence_id}")
    base_action = try(seq.base_action, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.base_action)
    type        = try(seq.type, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.type)
    ip_type     = lookup({ "both" = "all" }, try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol), try(seq.protocol, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.sequences.protocol))
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
          region      = region
          sub_regions = null # not supported in the UI
        }]
      }] : [],
      try(seq.match_entries.path_type, null) != null ? [{
        path_type = seq.match_entries.path_type
      }] : [],
      try(seq.match_entries.tloc.list, null) != null ? [{
        tloc_list_id = sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.match_entries.tloc.list].id
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
      try(seq.match_entries.role, null) != null ? [{
        role = lookup({ "border" = "border-router", "edge" = "edge-router" }, try(seq.match_entries.role, ""), null)
      }] : [],
      try(seq.match_entries.tloc.ip, null) != null ? [{
        tloc_ip            = seq.match_entries.tloc.ip
        tloc_color         = try(seq.match_entries.tloc.color, null)
        tloc_encapsulation = try(seq.match_entries.tloc.encapsulation, null)
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
        try(seq.action_entries.service, null) != null,
        try(seq.action_entries.service_chain, null) != null,
        try(seq.action_entries.tloc_action, null) != null,
        try(seq.action_entries.tloc, null) != null,
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
          try(seq.action_entries.service, null) != null ? [{
            service_type               = try(seq.action_entries.service.type, null)
            service_vpn                = try(seq.action_entries.service.vpn, null)
            service_tloc_ip            = try(seq.action_entries.service.tloc_ip, null)
            service_tloc_color         = try(seq.action_entries.service.tloc_color, null)
            service_tloc_encapsulation = try(seq.action_entries.service.tloc_encapsulation, null)
            service_tloc_list_id       = try(seq.action_entries.service.tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.service.tloc_list].id : null
          }] : [],
          try(seq.action_entries.service_chain, null) != null ? [{
            service_chain_type               = try(seq.action_entries.service_chain.name, null)
            service_chain_vpn                = try(seq.action_entries.service_chain.vpn, null)
            service_chain_tloc_ip            = try(seq.action_entries.service_chain.tloc_ip, null)
            service_chain_tloc_color         = try(seq.action_entries.service_chain.tloc_color, null)
            service_chain_tloc_encapsulation = try(seq.action_entries.service_chain.tloc_encapsulation, null)
            service_chain_tloc_list_id       = try(seq.action_entries.service_chain.tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.service_chain.tloc_list].id : null
          }] : [],
          try(seq.action_entries.tloc_action, null) != null ? [{
            tloc_action = seq.action_entries.tloc_action
          }] : [],
          try(seq.action_entries.tloc.ip, null) != null ? [{
            tloc_ip            = seq.action_entries.tloc.ip
            tloc_color         = try(seq.action_entries.tloc.color, null)
            tloc_encapsulation = try(seq.action_entries.tloc.encapsulation, null)
          }] : [],
          try(seq.action_entries.tloc.list, null) != null ? [{
            tloc_list_id = sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.action_entries.tloc.list].id
          }] : [],
        ])
      }] : [],
    ])
  }]
}

resource "sdwan_topology_hub_spoke_feature" "topology_hub_spoke_feature" {
  for_each = {
    for hub_spoke_item in flatten([
      for profile in try(local.feature_profiles.topology_profiles, []) : [
        for hub_spoke in try(profile.hub_spoke_policies, []) : {
          profile   = profile
          hub_spoke = hub_spoke
        }
      ]
    ])
    : "${hub_spoke_item.profile.name}-${hub_spoke_item.hub_spoke.name}" => hub_spoke_item
  }
  name               = each.value.hub_spoke.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  target_vpns        = each.value.hub_spoke.lan_vpn_names
  selected_hubs      = each.value.hub_spoke.selected_hub_sites
  spokes = try(length(each.value.hub_spoke.spoke_groups) == 0, true) ? null : [for spoke in try(each.value.hub_spoke.spoke_groups, []) : {
    name        = try(spoke.name, null)
    spoke_sites = try(spoke.spoke_sites, null)
    hub_sites = try(length(spoke.hub_preferences) == 0, true) ? null : [for hub_pref in try(spoke.hub_preferences, []) : {
      sites      = try(hub_pref.hub_sites, null)
      preference = try(hub_pref.preference, null)
    }]
  }]
}

resource "sdwan_topology_mesh_feature" "topology_mesh_feature" {
  for_each = {
    for mesh_item in flatten([
      for profile in try(local.feature_profiles.topology_profiles, []) : [
        for mesh in try(profile.mesh_policies, []) : {
          profile = profile
          mesh    = mesh
        }
      ]
    ])
    : "${mesh_item.profile.name}-${mesh_item.mesh.name}" => mesh_item
  }
  name               = each.value.mesh.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  target_vpns        = each.value.mesh.lan_vpn_names
  sites              = each.value.mesh.sites
}
