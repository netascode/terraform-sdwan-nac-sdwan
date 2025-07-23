resource "sdwan_service_routing_bgp_feature" "service_routing_bgp_feature" {
  for_each = {
    for bgp_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for bgp in try(profile.bgp_features, []) : {
          profile = profile
          bgp     = bgp
        }
      ]
    ])
    : "${bgp_item.profile.name}-${bgp_item.bgp.name}" => bgp_item
  }
  name                              = each.value.bgp.name
  description                       = try(each.value.bgp.description, null)
  feature_profile_id                = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  always_compare_med                = try(each.value.bgp.always_compare_med, null)
  always_compare_med_variable       = try("{{${each.value.bgp.always_compare_med_variable}}}", null)
  as_number                         = try(each.value.bgp.as_number, null)
  as_number_variable                = try("{{${each.value.bgp.as_number_variable}}}", null)
  compare_router_id                 = try(each.value.bgp.compare_router_id, null)
  compare_router_id_variable        = try("{{${each.value.bgp.compare_router_id_variable}}}", null)
  deterministic_med                 = try(each.value.bgp.deterministic_med, null)
  deterministic_med_variable        = try("{{${each.value.bgp.deterministic_med_variable}}}", null)
  external_routes_distance          = try(each.value.bgp.external_routes_distance, null)
  external_routes_distance_variable = try("{{${each.value.bgp.external_routes_distance_variable}}}", null)
  hold_time                         = try(each.value.bgp.hold_time, null)
  hold_time_variable                = try("{{${each.value.bgp.hold_time_variable}}}", null)
  internal_routes_distance          = try(each.value.bgp.internal_routes_distance, null)
  internal_routes_distance_variable = try("{{${each.value.bgp.internal_routes_distance_variable}}}", null)
  ipv4_aggregate_addresses = try(length(each.value.bgp.ipv4_aggregate_addresses) == 0, true) ? null : [for a in each.value.bgp.ipv4_aggregate_addresses : {
    as_set_path              = try(a.as_set_path, null)
    as_set_path_variable     = try("{{${a.as_set_path_variable}}}", null)
    network_address          = try(a.network_address, null)
    network_address_variable = try("{{${a.network_address_variable}}}", null)
    subnet_mask              = try(a.subnet_mask, null)
    subnet_mask_variable     = try("{{${a.subnet_mask_variable}}}", null)
    summary_only             = try(a.summary_only, null)
    summary_only_variable    = try("{{${a.summary_only_variable}}}", null)
  }]
  ipv4_eibgp_maximum_paths          = try(each.value.bgp.ipv4_eibgp_maximum_paths, null)
  ipv4_eibgp_maximum_paths_variable = try("{{${each.value.bgp.ipv4_eibgp_maximum_paths_variable}}}", null)
  ipv4_neighbors = try(length(each.value.bgp.ipv4_neighbors) == 0, true) ? null : [for neighbor in each.value.bgp.ipv4_neighbors : {
    address          = try(neighbor.address, null)
    address_variable = try("{{${neighbor.address_variable}}}", null)
    address_families = try(length(neighbor.address_families) == 0, true) ? null : [for address_family in neighbor.address_families : {
      family_type                                     = address_family.family_type
      in_route_policy_id                              = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_in}"].id, null)
      max_number_of_prefixes                          = try(address_family.maximum_prefixes_number, null)
      max_number_of_prefixes_variable                 = try("{{${address_family.maximum_prefixes_number_variable}}}", null)
      out_route_policy_id                             = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_out}"].id, null)
      policy_type                                     = try(address_family.maximum_prefixes_reach_policy, local.defaults.sdwan.feature_profiles.transport_profiles.bgp_features.ipv4_neighbors.address_families.maximum_prefixes_reach_policy)
      restart_interval                                = try(address_family.maximum_prefixes_restart_interval, null)
      restart_interval_variable                       = try("{{${address_family.maximum_prefixes_restart_interval_variable}}}", null)
      restart_max_number_of_prefixes                  = try(address_family.maximum_prefixes_reach_policy == "restart" ? address_family.maximum_prefixes_number : null, null)
      restart_max_number_of_prefixes_variable         = try(address_family.maximum_prefixes_reach_policy == "restart" ? address_family.maximum_prefixes_number_variable : null, null)
      restart_threshold                               = try(address_family.maximum_prefixes_reach_policy == "restart" ? address_family.maximum_prefixes_threshold : null, null)
      restart_threshold_variable                      = try(address_family.maximum_prefixes_reach_policy == "restart" ? address_family.maximum_prefixes_threshold_variable : null, null)
      warning_message_max_number_of_prefixes          = try(address_family.maximum_prefixes_reach_policy == "warning-only" ? address_family.maximum_prefixes_number : null, null)
      warning_message_max_number_of_prefixes_variable = try(address_family.maximum_prefixes_reach_policy == "warning-only" ? address_family.maximum_prefixes_number_variable : null, null)
      warning_message_threshold                       = try(address_family.maximum_prefixes_reach_policy == "warning-only" ? address_family.maximum_prefixes_threshold : null, null)
      warning_message_threshold_variable              = try(address_family.maximum_prefixes_reach_policy == "warning-only" ? address_family.maximum_prefixes_threshold_variable : null, null)
    }]
    allowas_in_number                = try(neighbor.allowas_in_number, null)
    allowas_in_number_variable       = try("{{${neighbor.allowas_in_number_variable}}}", null)
    as_override                      = try(neighbor.as_override, null)
    as_override_variable             = try("{{${neighbor.as_override_variable}}}", null)
    description                      = try(neighbor.description, null)
    description_variable             = try("{{${neighbor.description_variable}}}", null)
    ebgp_multihop                    = try(neighbor.ebgp_multihop, null)
    ebgp_multihop_variable           = try("{{${neighbor.ebgp_multihop_variable}}}", null)
    hold_time                        = try(neighbor.hold_time, null)
    hold_time_variable               = try("{{${neighbor.hold_time_variable}}}", null)
    keepalive_time                   = try(neighbor.keepalive_time, null)
    keepalive_time_variable          = try("{{${neighbor.keepalive_time_variable}}}", null)
    local_as                         = try(neighbor.local_as, null)
    local_as_variable                = try("{{${neighbor.local_as_variable}}}", null)
    next_hop_self                    = try(neighbor.next_hop_self, null)
    next_hop_self_variable           = try("{{${neighbor.next_hop_self_variable}}}", null)
    password                         = try(neighbor.password, null)
    password_variable                = try("{{${neighbor.password_variable}}}", null)
    remote_as                        = try(neighbor.remote_as, null)
    remote_as_variable               = try("{{${neighbor.remote_as_variable}}}", null)
    send_community                   = try(neighbor.send_community, null)
    send_community_variable          = try("{{${neighbor.send_community_variable}}}", null)
    send_extended_community          = try(neighbor.send_extended_community, null)
    send_extended_community_variable = try("{{${neighbor.send_extended_community_variable}}}", null)
    send_label                       = try(neighbor.send_label, null)
    shutdown                         = try(neighbor.shutdown, null)
    shutdown_variable                = try("{{${neighbor.shutdown_variable}}}", null)
    update_source_interface          = try(neighbor.source_interface, null)
    update_source_interface_variable = try("{{${neighbor.source_interface_variable}}}", null)
  }]
  ipv4_networks = try(length(each.value.bgp.ipv4_networks) == 0, true) ? null : [for network in each.value.bgp.ipv4_networks : {
    network_address          = try(network.network_address, null)
    network_address_variable = try("{{${network.network_address_variable}}}", null)
    subnet_mask              = try(network.subnet_mask, null)
    subnet_mask_variable     = try("{{${network.subnet_mask_variable}}}", null)
  }]
  ipv4_originate          = try(each.value.bgp.ipv4_default_originate, null)
  ipv4_originate_variable = try("{{${each.value.bgp.ipv4_default_originate_variable}}}", null)
  ipv4_redistributes = try(length(each.value.bgp.ipv4_redistributes) == 0, true) ? null : [for redistribute in each.value.bgp.ipv4_redistributes : {
    protocol                      = try(redistribute.protocol, null)
    protocol_variable             = try("{{${redistribute.protocol_variable}}}", null)
    route_policy_id               = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  ipv4_table_map_filter          = try(each.value.bgp.ipv4_table_map_filter, null)
  ipv4_table_map_filter_variable = try("{{${each.value.bgp.ipv4_table_map_filter_variable}}}", null)
  ipv4_table_map_route_policy_id = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${each.value.bgp.ipv4_table_map_route_policy}"].id, null)
  ipv6_aggregate_addresses = try(length(each.value.bgp.ipv6_aggregate_addresses) == 0, true) ? null : [for a in each.value.bgp.ipv6_aggregate_addresses : {
    aggregate_prefix          = try(a.prefix, null)
    aggregate_prefix_variable = try("{{${a.prefix_variable}}}", null)
    as_set_path               = try(a.as_set_path, null)
    as_set_path_variable      = try("{{${a.as_set_path_variable}}}", null)
    summary_only              = try(a.summary_only, null)
    summary_only_variable     = try("{{${a.summary_only_variable}}}", null)
  }]
  ipv6_eibgp_maximum_paths          = try(each.value.bgp.ipv6_eibgp_maximum_paths, null)
  ipv6_eibgp_maximum_paths_variable = try("{{${each.value.bgp.ipv6_eibgp_maximum_paths_variable}}}", null)
  ipv6_neighbors = try(length(each.value.bgp.ipv6_neighbors) == 0, true) ? null : [for neighbor in each.value.bgp.ipv6_neighbors : {
    address          = try(neighbor.address, null)
    address_variable = try("{{${neighbor.address_variable}}}", null)
    address_families = try(length(neighbor.address_families) == 0, true) ? null : [for address_family in neighbor.address_families : {
      family_type                     = address_family.family_type
      in_route_policy_id              = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_in}"].id, null)
      max_number_of_prefixes          = try(address_family.maximum_prefixes_number, null)
      max_number_of_prefixes_variable = try("{{${address_family.maximum_prefixes_number_variable}}}", null)
      out_route_policy_id             = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_out}"].id, null)
      policy_type                     = try(address_family.maximum_prefixes_reach_policy, local.defaults.sdwan.feature_profiles.transport_profiles.bgp_features.ipv6_neighbors.address_families.maximum_prefixes_reach_policy)
      restart_interval                = try(address_family.maximum_prefixes_restart_interval, null)
      restart_interval_variable       = try("{{${address_family.maximum_prefixes_restart_interval_variable}}}", null)
      threshold                       = try(address_family.maximum_prefixes_threshold, null)
      threshold_variable              = try("{{${address_family.maximum_prefixes_threshold_variable}}}", null)
    }]
    allowas_in_number                = try(neighbor.allowas_in_number, null)
    allowas_in_number_variable       = try("{{${neighbor.allowas_in_number_variable}}}", null)
    as_override                      = try(neighbor.as_override, null)
    as_override_variable             = try("{{${neighbor.as_override_variable}}}", null)
    description                      = try(neighbor.description, null)
    description_variable             = try("{{${neighbor.description_variable}}}", null)
    ebgp_multihop                    = try(neighbor.ebgp_multihop, null)
    ebgp_multihop_variable           = try("{{${neighbor.ebgp_multihop_variable}}}", null)
    hold_time                        = try(neighbor.hold_time, null)
    hold_time_variable               = try("{{${neighbor.hold_time_variable}}}", null)
    keepalive_time                   = try(neighbor.keepalive_time, null)
    keepalive_time_variable          = try("{{${neighbor.keepalive_time_variable}}}", null)
    local_as                         = try(neighbor.local_as, null)
    local_as_variable                = try("{{${neighbor.local_as_variable}}}", null)
    next_hop_self                    = try(neighbor.next_hop_self, null)
    next_hop_self_variable           = try("{{${neighbor.next_hop_self_variable}}}", null)
    password                         = try(neighbor.password, null)
    password_variable                = try("{{${neighbor.password_variable}}}", null)
    remote_as                        = try(neighbor.remote_as, null)
    remote_as_variable               = try("{{${neighbor.remote_as_variable}}}", null)
    send_community                   = try(neighbor.send_community, null)
    send_community_variable          = try("{{${neighbor.send_community_variable}}}", null)
    send_extended_community          = try(neighbor.send_extended_community, null)
    send_extended_community_variable = try("{{${neighbor.send_extended_community_variable}}}", null)
    send_label                       = try(neighbor.send_label, null)
    shutdown                         = try(neighbor.shutdown, null)
    shutdown_variable                = try("{{${neighbor.shutdown_variable}}}", null)
    update_source_interface          = try(neighbor.source_interface, null)
    update_source_interface_variable = try("{{${neighbor.source_interface_variable}}}", null)
  }]
  ipv6_networks = try(length(each.value.bgp.ipv6_networks) == 0, true) ? null : [for network in each.value.bgp.ipv6_networks : {
    network_prefix          = try(network.prefix, null)
    network_prefix_variable = try("{{${network.prefix_variable}}}", null)
  }]
  ipv6_originate          = try(each.value.bgp.ipv6_default_originate, null)
  ipv6_originate_variable = try("{{${each.value.bgp.ipv6_default_originate_variable}}}", null)
  ipv6_redistributes = try(length(each.value.bgp.ipv6_redistributes) == 0, true) ? null : [for redistribute in each.value.bgp.ipv6_redistributes : {
    protocol                      = try(redistribute.protocol, null)
    protocol_variable             = try("{{${redistribute.protocol_variable}}}", null)
    route_policy_id               = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  ipv6_table_map_filter          = try(each.value.bgp.ipv6_table_map_filter, null)
  ipv6_table_map_filter_variable = try("{{${each.value.bgp.ipv6_table_map_filter_variable}}}", null)
  ipv6_table_map_route_policy_id = try(sdwan_transport_route_policy_feature.transport_route_policy_feature["${each.value.profile.name}-${each.value.bgp.ipv6_table_map_route_policy}"].id, null)
  keepalive_time                 = try(each.value.bgp.keepalive_time, null)
  keepalive_time_variable        = try("{{${each.value.bgp.keepalive_time_variable}}}", null)
  local_routes_distance          = try(each.value.bgp.local_routes_distance, null)
  local_routes_distance_variable = try("{{${each.value.bgp.local_routes_distance_variable}}}", null)
  missing_med_as_worst           = try(each.value.bgp.missing_med_as_worst, null)
  missing_med_as_worst_variable  = try("{{${each.value.bgp.missing_med_as_worst_variable}}}", null)
  multipath_relax                = try(each.value.bgp.multipath_relax, null)
  multipath_relax_variable       = try("{{${each.value.bgp.multipath_relax_variable}}}", null)
  propagate_as_path              = try(each.value.bgp.propagate_as_path, null)
  propagate_as_path_variable     = try("{{${each.value.bgp.propagate_as_path_variable}}}", null)
  propagate_community            = try(each.value.bgp.propagate_community, null)
  propagate_community_variable   = try("{{${each.value.bgp.propagate_community_variable}}}", null)
  router_id                      = try(each.value.bgp.router_id, null)
  router_id_variable             = try("{{${each.value.bgp.router_id_variable}}}", null)
}

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
  object_tracker_type        = each.value.tracker.type
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
      as_path_prepend    = try(a.prepend_as_paths, null)
      community          = try(a.communities, null)
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
