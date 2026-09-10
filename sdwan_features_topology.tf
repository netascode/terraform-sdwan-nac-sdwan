locals {
  # Every site name topology references literally. Group names are deliberately
  # excluded: a group expands to sites taken from the hierarchy itself, so those
  # always resolve, and only literal names can be typos.
  nh_topology_site_refs = distinct(flatten([
    for profile in try(local.feature_profiles.topology_profiles, []) : [
      [for policy in try(profile.custom_policies, []) : concat(
        try(policy.inbound_sites, []),
        try(policy.outbound_sites, []),
        flatten([for seq in try(policy.sequences, []) : try(seq.match_entries.sites, [])]),
      )],
      [for policy in try(profile.mesh_policies, []) : try(policy.sites, [])],
      [for policy in try(profile.hub_spoke_policies, []) : concat(
        try(policy.selected_hub_sites, []),
        flatten([for spoke in try(policy.spoke_groups, []) : concat(
          try(spoke.spoke_sites, []),
          flatten([for hub_pref in try(spoke.hub_preferences, []) : try(hub_pref.hub_sites, [])]),
        )]),
      )],
    ]
  ]))

  # One wire family for the whole deployment: oneOf forbids mixing UUIDs and
  # site names within a policy, and site names work on both Manager versions,
  # so a per-policy mix would buy nothing.
  #
  # Coarse on purpose - whether the hierarchy declares any sites, not whether
  # every reference resolves; an unresolvable name fails the plan instead
  # (see output.topology_site_resolution below).
  nh_uuid_mode = local.nh_version_supports_uuids && length(local.nh_site_names) > 0

  # Literal site names topology references that the hierarchy does not declare.
  # Only meaningful in UUID mode: names mode sends them as-is.
  nh_unresolved_site_refs = [
    for name in local.nh_topology_site_refs : name
    if !contains(local.nh_site_names, name)
  ]
}

# Named failure for an unresolvable site name, instead of a bare "Invalid
# index" from local.nh_site_name_to_id further down.
#
# An output precondition rather than a resource: it fails the plan the same
# way, and also propagates when this module is used as a child module.
output "topology_site_resolution" {
  value = null
  precondition {
    condition = !local.nh_uuid_mode || length(local.nh_unresolved_site_refs) == 0
    error_message = format(
      "Topology policies reference site(s) %v which are not declared under `sdwan.network_hierarchy`. On Manager 20.18.1+ site targeting is sent as hierarchy UUIDs, which can only be resolved for declared sites. Declare the missing sites under `sdwan.network_hierarchy`, or set `sdwan.manager_version` to 20.15 to send site names instead.",
      local.nh_unresolved_site_refs,
    )
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
    : "${custom_control_item.profile.name}-${custom_control_item.custom_control.name}" => merge(custom_control_item, {
      # Expanded once here; indexed without a lookup() default so an unknown
      # group name fails the plan instead of silently deploying fewer sites.
      inbound_site_names = distinct(concat(
        try(custom_control_item.custom_control.inbound_sites, []),
        flatten([for g in try(custom_control_item.custom_control.inbound_site_groups, []) : local.nh_container_sites[g]]),
      ))
      outbound_site_names = distinct(concat(
        try(custom_control_item.custom_control.outbound_sites, []),
        flatten([for g in try(custom_control_item.custom_control.outbound_site_groups, []) : local.nh_container_sites[g]]),
      ))
      sequences = [for seq in try(custom_control_item.custom_control.sequences, []) : merge(seq, {
        match_site_names = distinct(concat(
          try(seq.match_entries.sites, []),
          flatten([for g in try(seq.match_entries.site_groups, []) : local.nh_container_sites[g]]),
        ))
      })]
    })
  }
  name               = each.value.custom_control.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  default_action     = try(each.value.custom_control.default_action, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.default_action)
  target_level       = lookup({ "sites" = "SITE", "wan_regions" = "REGION" }, try(each.value.custom_control.level, local.defaults.sdwan.feature_profiles.topology_profiles.custom_policies.level), null)
  target_vpn         = null # not supported in the UI
  target_role        = lookup({ "border" = "border-router", "edge" = "edge-router" }, try(each.value.custom_control.role, ""), null)
  # A direction with nothing configured stays null so the attribute is omitted;
  # the provider's force_include supplies the empty array the GUI sends for the
  # unconfigured direction when the other one is set.
  target_inbound_sites            = local.nh_uuid_mode || length(each.value.inbound_site_names) == 0 ? null : each.value.inbound_site_names
  target_outbound_sites           = local.nh_uuid_mode || length(each.value.outbound_site_names) == 0 ? null : each.value.outbound_site_names
  target_inbound_hierarchy_uuids  = local.nh_uuid_mode && length(each.value.inbound_site_names) > 0 ? [for s in each.value.inbound_site_names : local.nh_site_name_to_id[s]] : null
  target_outbound_hierarchy_uuids = local.nh_uuid_mode && length(each.value.outbound_site_names) > 0 ? [for s in each.value.outbound_site_names : local.nh_site_name_to_id[s]] : null
  target_inbound_regions = try(length(each.value.custom_control.inbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.inbound_regions, []) : {
    region = region
  }]
  target_outbound_regions = try(length(each.value.custom_control.outbound_regions) == 0, true) ? null : [for region in try(each.value.custom_control.outbound_regions, []) : {
    region = region
  }]
  sequences = length(each.value.sequences) == 0 ? null : [for seq in each.value.sequences : {
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
      # The 20.18 GUI renders this match entry only with hierarchy UUIDs; a
      # site name is accepted by the API but shows blank there.
      length(seq.match_site_names) > 0 ? [
        local.nh_uuid_mode
        ? { hierarchy_uuids = [for s in seq.match_site_names : local.nh_site_name_to_id[s]] }
        : { site = seq.match_site_names }
      ] : [],
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
    : "${hub_spoke_item.profile.name}-${hub_spoke_item.hub_spoke.name}" => merge(hub_spoke_item, {
      # Only spoke_sites is group-expandable; hub sites stay literal lists so
      # the hub set is always explicit.
      selected_hub_site_names = distinct(try(hub_spoke_item.hub_spoke.selected_hub_sites, []))
      spoke_groups = [for spoke in try(hub_spoke_item.hub_spoke.spoke_groups, []) : merge(spoke, {
        site_names = distinct(concat(
          try(spoke.spoke_sites, []),
          flatten([for g in try(spoke.spoke_site_groups, []) : local.nh_container_sites[g]]),
        ))
        hub_preferences = [for hub_pref in try(spoke.hub_preferences, []) : merge(hub_pref, {
          site_names = distinct(try(hub_pref.hub_sites, []))
        })]
      })]
    })
  }
  name               = each.value.hub_spoke.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  target_vpns        = each.value.hub_spoke.lan_vpn_names
  # All three arrays are minItems:1 in the API, so none of them gets the
  # empty-array fallback the custom_control target uses.
  selected_hubs           = local.nh_uuid_mode ? null : each.value.selected_hub_site_names
  selected_hierarchy_hubs = local.nh_uuid_mode ? [for s in each.value.selected_hub_site_names : local.nh_site_name_to_id[s]] : null
  spokes = length(each.value.spoke_groups) == 0 ? null : [for spoke in each.value.spoke_groups : {
    name                  = try(spoke.name, null)
    spoke_sites           = local.nh_uuid_mode ? null : spoke.site_names
    spoke_hierarchy_uuids = local.nh_uuid_mode ? [for s in spoke.site_names : local.nh_site_name_to_id[s]] : null
    hub_sites = length(spoke.hub_preferences) == 0 ? null : [for hub_pref in spoke.hub_preferences : {
      sites               = local.nh_uuid_mode ? null : hub_pref.site_names
      hub_hierarchy_uuids = local.nh_uuid_mode ? [for s in hub_pref.site_names : local.nh_site_name_to_id[s]] : null
      preference          = try(hub_pref.preference, null)
    }]
  }]
  lifecycle {
    precondition {
      condition = alltrue(concat(
        [length(each.value.selected_hub_site_names) > 0],
        [for spoke in each.value.spoke_groups : length(spoke.site_names) > 0],
        flatten([for spoke in each.value.spoke_groups : [
          for hub_pref in spoke.hub_preferences : length(hub_pref.site_names) > 0
        ]]),
      ))
      error_message = format(
        "Hub-and-spoke policy '%s' has site selection(s) that resolve to no sites: %v. All three arrays require at least one site. selected_hub_sites and hub_sites are required lists, so an empty one here means the schema was bypassed; a spoke_site_groups entry expanding to no sites is the more likely cause.",
        each.value.hub_spoke.name,
        concat(
          length(each.value.selected_hub_site_names) == 0 ? ["selected_hub_sites"] : [],
          flatten([for spoke in each.value.spoke_groups : concat(
            length(spoke.site_names) == 0 ? ["spoke_groups['${try(spoke.name, "?")}'].spoke_sites/spoke_site_groups"] : [],
            [
              for hub_pref in spoke.hub_preferences :
              "spoke_groups['${try(spoke.name, "?")}'].hub_preferences.hub_sites"
              if length(hub_pref.site_names) == 0
            ],
          )]),
        ),
      )
    }
  }
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
    : "${mesh_item.profile.name}-${mesh_item.mesh.name}" => merge(mesh_item, {
      site_names = distinct(concat(
        try(mesh_item.mesh.sites, []),
        flatten([for g in try(mesh_item.mesh.site_groups, []) : local.nh_container_sites[g]]),
      ))
    })
  }
  name               = each.value.mesh.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_topology_feature_profile.topology_feature_profile[each.value.profile.name].id
  target_vpns        = each.value.mesh.lan_vpn_names
  # Unlike the custom_control target, these arrays are minItems:1 in the API, so
  # there is no empty-array fallback here - the precondition below rejects an
  # empty expansion instead of emitting [] into either family.
  sites           = local.nh_uuid_mode ? null : each.value.site_names
  hierarchy_uuids = local.nh_uuid_mode ? [for s in each.value.site_names : local.nh_site_name_to_id[s]] : null
  lifecycle {
    precondition {
      condition     = length(each.value.site_names) > 0
      error_message = "Mesh policy '${each.value.mesh.name}' resolves to no sites, but the API requires at least one - every site group listed here must contain at least one site."
    }
  }
}
