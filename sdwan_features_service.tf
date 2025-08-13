resource "sdwan_service_dhcp_server_feature" "service_dhcp_server_feature" {
  for_each = {
    for dhcp_server_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for dhcp_server in try(profile.dhcp_servers, []) : {
          profile     = profile
          dhcp_server = dhcp_server
        }
      ]
    ])
    : "${dhcp_server_item.profile.name}-${dhcp_server_item.dhcp_server.name}" => dhcp_server_item
  }
  name                     = each.value.dhcp_server.name
  description              = try(each.value.dhcp_server.description, null)
  feature_profile_id       = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  network_address          = try(each.value.dhcp_server.pool_network_address, null)
  network_address_variable = try("{{${each.value.dhcp_server.pool_network_address_variable}}}", null)
  subnet_mask              = try(each.value.dhcp_server.pool_subnet_mask, null)
  subnet_mask_variable     = try("{{${each.value.dhcp_server.pool_subnet_mask_variable}}}", null)
  default_gateway          = try(each.value.dhcp_server.default_gateway, null)
  default_gateway_variable = try("{{${each.value.dhcp_server.default_gateway_variable}}}", null)
  dns_servers              = try(each.value.dhcp_server.dns_servers, null)
  dns_servers_variable     = try("{{${each.value.dhcp_server.dns_servers_variable}}}", null)
  domain_name              = try(each.value.dhcp_server.domain_name, null)
  domain_name_variable     = try("{{${each.value.dhcp_server.domain_name_variable}}}", null)
  exclude                  = try(each.value.dhcp_server.exclude_addresses, null)
  exclude_variable         = try("{{${each.value.dhcp_server.exclude_addresses_variable}}}", null)
  interface_mtu            = try(each.value.dhcp_server.interface_mtu, null)
  interface_mtu_variable   = try("{{${each.value.dhcp_server.interface_mtu_variable}}}", null)
  lease_time               = try(each.value.dhcp_server.lease_time, null)
  lease_time_variable      = try("{{${each.value.dhcp_server.lease_time_variable}}}", null)
  tftp_servers             = try(each.value.dhcp_server.tftp_servers, null)
  tftp_servers_variable    = try("{{${each.value.dhcp_server.tftp_servers_variable}}}", null)
  option_codes = try(length(each.value.dhcp_server.options) == 0, true) ? null : [for option in each.value.dhcp_server.options : {
    ascii          = try(option.ascii, null)
    ascii_variable = try("{{${option.ascii_variable}}}", null)
    hex            = try(option.hex, null)
    hex_variable   = try("{{${option.hex_variable}}}", null)
    ip             = try(option.ip_addresses, null)
    ip_variable    = try("{{${option.ip_addresses_variable}}}", null)
    code           = try(option.code, null)
    code_variable  = try("{{${option.code_variable}}}", null)
  }]
  static_leases = try(length(each.value.dhcp_server.static_leases) == 0, true) ? null : [for lease in each.value.dhcp_server.static_leases : {
    ip_address           = try(lease.ip_address, null)
    ip_address_variable  = try("{{${lease.ip_address_variable}}}", null)
    mac_address          = try(lease.mac_address, null)
    mac_address_variable = try("{{${lease.mac_address_variable}}}", null)
  }]
}

resource "sdwan_service_tracker_group_feature" "service_tracker_group_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for tracker in try(profile.ipv4_tracker_groups, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                     = each.value.tracker.name
  description              = try(each.value.tracker.description, null)
  feature_profile_id       = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  tracker_boolean          = try(each.value.tracker.tracker_boolean, null)
  tracker_boolean_variable = try("{{${each.value.tracker.tracker_boolean_variable}}}", null)
  tracker_elements = try(length(each.value.tracker.trackers) == 0, true) ? null : [for t in each.value.tracker.trackers : {
    tracker_id = sdwan_service_tracker_feature.service_tracker_feature["${each.value.profile.name}-${t}"].id
  }]
}

resource "sdwan_service_tracker_feature" "service_tracker_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for tracker in try(profile.ipv4_trackers, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                      = each.value.tracker.name
  description               = try(each.value.tracker.description, null)
  feature_profile_id        = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  endpoint_api_url          = try(each.value.tracker.endpoint_url, null)
  endpoint_api_url_variable = try("{{${each.value.tracker.endpoint_url_variable}}}", null)
  endpoint_ip               = try(each.value.tracker.endpoint_ip, null)
  endpoint_ip_variable      = try("{{${each.value.tracker.endpoint_ip_variable}}}", null)
  endpoint_tracker_type     = "static-route"
  interval                  = try(each.value.tracker.interval, null)
  interval_variable         = try("{{${each.value.tracker.interval_variable}}}", null)
  multiplier                = try(each.value.tracker.multiplier, null)
  multiplier_variable       = try("{{${each.value.tracker.multiplier_variable}}}", null)
  port                      = try(each.value.tracker.endpoint_port, null)
  port_variable             = try("{{${each.value.tracker.endpoint_port_variable}}}", null)
  protocol                  = try(each.value.tracker.endpoint_protocol, null)
  protocol_variable         = try("{{${each.value.tracker.endpoint_protocol_variable}}}", null)
  threshold                 = try(each.value.tracker.threshold, null)
  threshold_variable        = try("{{${each.value.tracker.threshold_variable}}}", null)
  tracker_name              = try(each.value.tracker.tracker_name, null)
  tracker_name_variable     = try("{{${each.value.tracker.tracker_name_variable}}}", null)
  tracker_type              = "endpoint"
}

resource "sdwan_service_object_tracker_group_feature" "service_object_tracker_group_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for tracker in try(profile.object_tracker_groups, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                       = each.value.tracker.name
  description                = try(each.value.tracker.description, null)
  feature_profile_id         = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  object_tracker_id          = try(each.value.tracker.id, null)
  object_tracker_id_variable = try("{{${each.value.tracker.id_variable}}}", null)
  reachable                  = try(each.value.tracker.tracker_boolean, null)
  reachable_variable         = try("{{${each.value.tracker.tracker_boolean_variable}}}", null)
  tracker_elements = try(length(each.value.tracker.trackers) == 0, true) ? null : [for t in each.value.tracker.trackers : {
    object_tracker_id = sdwan_service_object_tracker_feature.service_object_tracker_feature["${each.value.profile.name}-${t}"].id
  }]
}

resource "sdwan_service_object_tracker_feature" "service_object_tracker_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for tracker in try(profile.object_trackers, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                       = each.value.tracker.name
  description                = try(each.value.tracker.description, null)
  feature_profile_id         = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  object_tracker_type        = each.value.tracker.type == "sig" ? "SIG" : title(each.value.tracker.type)
  interface                  = try(each.value.tracker.interface_name, null)
  interface_variable         = try("{{${each.value.tracker.interface_name_variable}}}", null)
  object_tracker_id          = try(each.value.tracker.id, null)
  object_tracker_id_variable = try("{{${each.value.tracker.id_variable}}}", null)
  route_ip                   = try(each.value.tracker.route_ip, null)
  route_ip_variable          = try("{{${each.value.tracker.route_ip_variable}}}", null)
  route_mask                 = try(each.value.tracker.route_mask, null)
  route_mask_variable        = try("{{${each.value.tracker.route_mask_variable}}}", null)
  vpn                        = try(each.value.tracker.vpn_id, null)
  vpn_variable               = try("{{${each.value.tracker.vpn_id_variable}}}", null)
}

resource "sdwan_service_route_policy_feature" "service_route_policy_feature" {
  for_each = {
    for route_policy_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for route_policy in try(profile.route_policies, []) : {
          profile      = profile
          route_policy = route_policy
        }
      ]
    ])
    : "${route_policy_item.profile.name}-${route_policy_item.route_policy.name}" => route_policy_item
  }
  name               = each.value.route_policy.name
  description        = try(each.value.route_policy.description, null)
  feature_profile_id = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  default_action     = try(each.value.route_policy.default_action, null)
  sequences = try(length(each.value.route_policy.sequences) == 0, true) ? null : [for s in each.value.route_policy.sequences : {
    actions = try(length(s.actions) == 0, true) ? null : [for a in [s.actions] : {
      as_path_prepend = try(a.prepend_as_paths, null)
      community = try(length(a.communities) == 0, true) ? null : [
        for c in a.communities : c == "local-as" ? "local-AS" : c
      ]
      community_additive = try(a.communities_additive, null)
      community_variable = try("{{${a.communities_variable}}}", null)
      ipv4_next_hop      = try(a.ipv4_next_hop, null)
      ipv6_next_hop      = try(a.ipv6_next_hop, null)
      local_preference   = try(a.bgp_local_preference, null)
      metric             = try(a.metric, null)
      metric_type        = try(a.metric_type, null)
      omp_tag            = try(a.omp_tag, null)
      origin = try(
        a.origin == "igp" ? "IGP" :
        a.origin == "egp" ? "EGP" :
        a.origin == "incomplete" ? "Incomplete" : null,
        null
      )
      ospf_tag = try(a.ospf_tag, null)
      weight   = try(a.weight, null)
    }]
    base_action = s.base_action
    id          = s.id
    match_entries = try(length(s.match_entries) == 0, true) ? null : [for m in [s.match_entries] : {
      as_path_list_id                  = try(sdwan_policy_object_as_path_list.policy_object_as_path_list[m.as_path_list].id, null)
      bgp_local_preference             = try(m.bgp_local_preference, null)
      expanded_community_list_id       = try(sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list[m.expanded_community_list].id, null)
      extended_community_list_id       = try(sdwan_policy_object_extended_community_list.policy_object_extended_community_list[m.extended_community_list].id, null)
      ipv4_address_prefix_list_id      = try(sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[m.ipv4_address_prefix_list].id, null)
      ipv4_next_hop_prefix_list_id     = try(sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[m.ipv4_next_hop_prefix_list].id, null)
      ipv6_address_prefix_list_id      = try(sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list[m.ipv6_address_prefix_list].id, null)
      ipv6_next_hop_prefix_list_id     = try(sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list[m.ipv6_next_hop_prefix_list].id, null)
      metric                           = try(m.metric, null)
      omp_tag                          = try(m.omp_tag, null)
      ospf_tag                         = try(m.ospf_tag, null)
      standard_community_list_criteria = try(upper(m.standard_community_lists_criteria), null)
      standard_community_lists = try(length(m.standard_community_lists) == 0, true) ? null : [for c in m.standard_community_lists : {
        id = try(sdwan_policy_object_standard_community_list.policy_object_standard_community_list[c].id, null)
      }]
    }]
    name     = try(s.name, local.defaults.sdwan.feature_profiles.service_profiles.route_policies.sequences.name)
    protocol = upper(try(s.protocol, local.defaults.sdwan.feature_profiles.transport_profiles.route_policies.sequences.protocol))
  }]
}
