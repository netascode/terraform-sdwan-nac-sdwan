resource "sdwan_embedded_security_ngfw_policy" "embedded_security_ngfw_policy" {
  for_each = {
    for item in flatten([
      for profile in try(local.feature_profiles.ngfw_security_profiles, []) : [
        for policy in try(profile.policies, []) : {
          profile = profile
          policy  = policy
        }
      ]
    ])
    : "${item.profile.name}-${item.policy.name}" => item
  }
  name               = each.value.policy.name
  description        = "NG Firewall policy"
  feature_profile_id = sdwan_embedded_security_feature_profile.embedded_security_feature_profile[each.value.profile.name].id
  default_action     = each.value.policy.default_action
  sequences = try(length(each.value.policy.sequences) == 0, true) ? null : [
    for seq in each.value.policy.sequences : {
      sequence_id      = tostring(seq.sequence_id)
      sequence_name    = seq.sequence_name
      base_action      = seq.base_action
      disable_sequence = try(seq.disable_sequence, local.defaults.sdwan.feature_profiles.ngfw_security_profiles.policies.sequences.disable_sequence)
      sequence_type    = try(seq.sequence_type, local.defaults.sdwan.feature_profiles.ngfw_security_profiles.policies.sequences.sequence_type)
      match_entries = try(seq.match_entries, null) == null ? null : flatten([
        try(seq.match_entries.application_list, null) != null ? [{
          app_list_ids = [sdwan_policy_object_security_local_application_list.policy_object_security_local_application_list[seq.match_entries.application_list].id]
        }] : [],
        try(seq.match_entries.destination_data_ipv4_prefix_lists, null) != null ? [{
          destination_data_prefix_list_ids = [for n in seq.match_entries.destination_data_ipv4_prefix_lists : sdwan_policy_object_security_data_ipv4_prefix_list.policy_object_security_data_ipv4_prefix_list[n].id]
        }] : [],
        try(seq.match_entries.destination_data_ipv4_prefixes, null) != null ? [{
          destination_data_prefixes = seq.match_entries.destination_data_ipv4_prefixes
        }] : [],
        try(seq.match_entries.destination_data_ipv4_prefixes_variable, null) != null ? [{
          destination_data_prefixes_variable = "{{${seq.match_entries.destination_data_ipv4_prefixes_variable}}}"
        }] : [],
        try(seq.match_entries.destination_fqdn_lists, null) != null ? [{
          destination_fqdn_list_ids = [for n in seq.match_entries.destination_fqdn_lists : sdwan_policy_object_security_fqdn_list.policy_object_security_fqdn_list[n].id]
        }] : [],
        try(seq.match_entries.destination_fqdns, null) != null ? [{
          destination_fqdns = seq.match_entries.destination_fqdns
        }] : [],
        try(seq.match_entries.destination_fqdns_variable, null) != null ? [{
          destination_fqdns_variable = "{{${seq.match_entries.destination_fqdns_variable}}}"
        }] : [],
        try(seq.match_entries.destination_geo_location_lists, null) != null ? [{
          destination_geo_location_list_ids = [for n in seq.match_entries.destination_geo_location_lists : sdwan_policy_object_security_geolocation_list.policy_object_security_geolocation_list[n].id]
        }] : [],
        try(seq.match_entries.destination_geo_locations, null) != null ? [{
          destination_geo_locations = seq.match_entries.destination_geo_locations
        }] : [],
        try(seq.match_entries.destination_geo_locations_variable, null) != null ? [{
          destination_geo_locations_variable = "{{${seq.match_entries.destination_geo_locations_variable}}}"
        }] : [],
        try(seq.match_entries.destination_port_lists, null) != null ? [{
          destination_port_list_ids = [for n in seq.match_entries.destination_port_lists : sdwan_policy_object_security_port_list.policy_object_security_port_list[n].id]
        }] : [],
        try(seq.match_entries.destination_ports, null) != null ? [{
          destination_ports = [for p in seq.match_entries.destination_ports : tostring(p)]
        }] : [],
        try(seq.match_entries.destination_ports_variable, null) != null ? [{
          destination_ports_variable = "{{${seq.match_entries.destination_ports_variable}}}"
        }] : [],
        try(seq.match_entries.destination_scalable_group_tag_lists, null) != null ? [{
          destination_scalable_group_tag_list_ids = seq.match_entries.destination_scalable_group_tag_lists
        }] : [],
        try(seq.match_entries.protocol_name_lists, null) != null ? [{
          protocol_name_list_ids = [for n in seq.match_entries.protocol_name_lists : sdwan_policy_object_security_protocol_list.policy_object_security_protocol_list[n].id]
        }] : [],
        try(seq.match_entries.protocol_names, null) != null ? [{
          protocol_names = seq.match_entries.protocol_names
        }] : [],
        try(seq.match_entries.protocols, null) != null ? [{
          protocols = [for p in seq.match_entries.protocols : tostring(p)]
        }] : [],
        try(seq.match_entries.source_data_ipv4_prefix_lists, null) != null ? [{
          source_data_prefix_list_ids = [for n in seq.match_entries.source_data_ipv4_prefix_lists : sdwan_policy_object_security_data_ipv4_prefix_list.policy_object_security_data_ipv4_prefix_list[n].id]
        }] : [],
        try(seq.match_entries.source_data_ipv4_prefixes, null) != null ? [{
          source_data_prefixes = seq.match_entries.source_data_ipv4_prefixes
        }] : [],
        try(seq.match_entries.source_data_ipv4_prefixes_variable, null) != null ? [{
          source_data_prefixes_variable = "{{${seq.match_entries.source_data_ipv4_prefixes_variable}}}"
        }] : [],
        try(seq.match_entries.source_geo_location_lists, null) != null ? [{
          source_geo_location_list_ids = [for n in seq.match_entries.source_geo_location_lists : sdwan_policy_object_security_geolocation_list.policy_object_security_geolocation_list[n].id]
        }] : [],
        try(seq.match_entries.source_geo_locations, null) != null ? [{
          source_geo_locations = seq.match_entries.source_geo_locations
        }] : [],
        try(seq.match_entries.source_geo_locations_variable, null) != null ? [{
          source_geo_locations_variable = "{{${seq.match_entries.source_geo_locations_variable}}}"
        }] : [],
        try(seq.match_entries.source_identity_lists, null) != null ? [{
          source_identity_list_ids = seq.match_entries.source_identity_lists
        }] : [],
        try(seq.match_entries.source_identity_usergroups, null) != null ? [{
          source_identity_usergroups = seq.match_entries.source_identity_usergroups
        }] : [],
        try(seq.match_entries.source_identity_users, null) != null ? [{
          source_identity_users = seq.match_entries.source_identity_users
        }] : [],
        try(seq.match_entries.source_port_lists, null) != null ? [{
          source_port_list_ids = [for n in seq.match_entries.source_port_lists : sdwan_policy_object_security_port_list.policy_object_security_port_list[n].id]
        }] : [],
        try(seq.match_entries.source_ports, null) != null ? [{
          source_ports = [for p in seq.match_entries.source_ports : tostring(p)]
        }] : [],
        try(seq.match_entries.source_ports_variable, null) != null ? [{
          source_ports_variable = "{{${seq.match_entries.source_ports_variable}}}"
        }] : [],
        try(seq.match_entries.source_scalable_group_tag_lists, null) != null ? [{
          source_scalable_group_tag_list_ids = seq.match_entries.source_scalable_group_tag_lists
        }] : [],
        # TODO 20.18: source/destination_security_group_list_ids — requires sdwan_policy_object_security_object_group (not available in 20.15)
      ])
      # Scenario 1 — pass/drop + log: true    → [{type=log, parameter="true"}]
      # Scenario 2 — inspect + no log + AIP   → [{type=advancedInspectionProfile, parameter_id=<uuid>}]
      # Scenario 3 — inspect + log + AIP      → [{type=connectionEvents, parameter="true"}, {type=advancedInspectionProfile, parameter_id=<uuid>}]
      # No action                             → null
      actions = (
        seq.base_action != "inspect"
        ? (
          try(seq.actions.log, local.defaults.sdwan.feature_profiles.ngfw_security_profiles.policies.sequences.actions.log, false) == true
          ? [{ type = "log", parameter = "true", parameter_id = null }]
          : null
        )
        : (
          try(seq.actions.advanced_inspection_profile, null) != null
          ? (
            try(seq.actions.log, local.defaults.sdwan.feature_profiles.ngfw_security_profiles.policies.sequences.actions.log, false) == true
            ? [
              { type = "connectionEvents", parameter = "true", parameter_id = null },
              { type = "advancedInspectionProfile", parameter = null, parameter_id = sdwan_policy_object_unified_advanced_inspection_profile.policy_object_unified_advanced_inspection_profile[seq.actions.advanced_inspection_profile].id }
            ]
            : [
              { type = "advancedInspectionProfile", parameter = null, parameter_id = sdwan_policy_object_unified_advanced_inspection_profile.policy_object_unified_advanced_inspection_profile[seq.actions.advanced_inspection_profile].id }
            ]
          )
          : null
        )
      )
    }
  ]
}

resource "sdwan_embedded_security_policy" "embedded_security_policy" {
  for_each = {
    for profile in try(local.feature_profiles.ngfw_security_profiles, []) : profile.name => profile
    if try(profile.settings, null) != null || try(profile.policies, null) != null
  }
  name                                     = each.value.name
  description                              = try(each.value.description, each.value.name)
  feature_profile_id                       = sdwan_embedded_security_feature_profile.embedded_security_feature_profile[each.key].id
  tcp_syn_flood_limit                      = try(tostring(each.value.settings.tcp_syn_flood_limit), null)
  max_incomplete_tcp_limit                 = try(tostring(each.value.settings.max_incomplete_tcp_limit), null)
  max_incomplete_udp_limit                 = try(tostring(each.value.settings.max_incomplete_udp_limit), null)
  max_incomplete_icmp_limit                = try(tostring(each.value.settings.max_incomplete_icmp_limit), null)
  audit_trail                              = try(each.value.settings.audit_trail, null)
  unified_logging                          = try(each.value.settings.unified_logging, null)
  session_reclassify_allow                 = try(each.value.settings.session_reclassify_allow, null)
  icmp_unreachable_allow                   = try(each.value.settings.icmp_unreachable_allow, null)
  failure_mode                             = try(each.value.settings.failure_mode, null)
  nat                                      = try(each.value.settings.app_hosting.nat, null)
  nat_variable                             = try("{{${each.value.settings.app_hosting.nat_variable}}}", null)
  download_url_database_on_device          = try(each.value.settings.app_hosting.download_url_database_on_device, null)
  download_url_database_on_device_variable = try("{{${each.value.settings.app_hosting.download_url_database_on_device_variable}}}", null)
  resource_profile                         = try(each.value.settings.app_hosting.resource_profile, null)
  resource_profile_variable                = try("{{${each.value.settings.app_hosting.resource_profile_variable}}}", null)
  assembly = concat(
    [
      for policy in try(each.value.policies, []) : {
        ngfw_policy_id = sdwan_embedded_security_ngfw_policy.embedded_security_ngfw_policy["${each.key}-${policy.name}"].id
        # Zone pairs: one source_zone + list of destination_zones from the data model.
        # Expand into one entry per destination zone, matching the flat entries[] the provider expects.
        entries = try(length(policy.destination_zones) == 0, true) ? null : [
          for dst in policy.destination_zones : {
            source_zone              = contains(["self", "no_zone", "untrusted"], try(policy.source_zone, "")) ? (policy.source_zone == "no_zone" ? "default" : policy.source_zone) : null
            source_zone_list_id      = contains(["self", "no_zone", "untrusted"], try(policy.source_zone, "")) ? null : sdwan_policy_object_security_zone.policy_object_security_zone[policy.source_zone].id
            destination_zone         = contains(["self", "no_zone", "untrusted"], dst) ? (dst == "no_zone" ? "default" : dst) : null
            destination_zone_list_id = contains(["self", "no_zone", "untrusted"], dst) ? null : sdwan_policy_object_security_zone.policy_object_security_zone[dst].id
          }
        ]
      }
    ],
    try(each.value.settings.advanced_inspection_profile, null) != null ? [{
      advanced_inspection_profile_policy_id = sdwan_policy_object_unified_advanced_inspection_profile.policy_object_unified_advanced_inspection_profile[each.value.settings.advanced_inspection_profile].id
    }] : []
    # ssl_decryption_profile_id not yet implemented
  )
}
