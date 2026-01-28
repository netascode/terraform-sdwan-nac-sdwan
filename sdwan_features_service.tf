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
      in_route_policy_id                              = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_in}"].id, null)
      max_number_of_prefixes                          = try(address_family.maximum_prefixes_number, null)
      max_number_of_prefixes_variable                 = try("{{${address_family.maximum_prefixes_number_variable}}}", null)
      out_route_policy_id                             = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_out}"].id, null)
      policy_type                                     = try(address_family.maximum_prefixes_reach_policy, local.defaults.sdwan.feature_profiles.service_profiles.bgp_features.ipv4_neighbors.address_families.maximum_prefixes_reach_policy)
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
    route_policy_id               = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  ipv4_table_map_filter          = try(each.value.bgp.ipv4_table_map_filter, null)
  ipv4_table_map_filter_variable = try("{{${each.value.bgp.ipv4_table_map_filter_variable}}}", null)
  ipv4_table_map_route_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${each.value.bgp.ipv4_table_map_route_policy}"].id, null)
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
      family_type                                     = address_family.family_type
      in_route_policy_id                              = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_in}"].id, null)
      max_number_of_prefixes                          = try(address_family.maximum_prefixes_number, null)
      max_number_of_prefixes_variable                 = try("{{${address_family.maximum_prefixes_number_variable}}}", null)
      out_route_policy_id                             = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${address_family.route_policy_out}"].id, null)
      policy_type                                     = try(address_family.maximum_prefixes_reach_policy, local.defaults.sdwan.feature_profiles.service_profiles.bgp_features.ipv6_neighbors.address_families.maximum_prefixes_reach_policy)
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
  ipv6_networks = try(length(each.value.bgp.ipv6_networks) == 0, true) ? null : [for network in each.value.bgp.ipv6_networks : {
    network_prefix          = try(network.prefix, null)
    network_prefix_variable = try("{{${network.prefix_variable}}}", null)
  }]
  ipv6_originate          = try(each.value.bgp.ipv6_default_originate, null)
  ipv6_originate_variable = try("{{${each.value.bgp.ipv6_default_originate_variable}}}", null)
  ipv6_redistributes = try(length(each.value.bgp.ipv6_redistributes) == 0, true) ? null : [for redistribute in each.value.bgp.ipv6_redistributes : {
    protocol                      = try(redistribute.protocol, null)
    protocol_variable             = try("{{${redistribute.protocol_variable}}}", null)
    route_policy_id               = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  ipv6_table_map_filter          = try(each.value.bgp.ipv6_table_map_filter, null)
  ipv6_table_map_filter_variable = try("{{${each.value.bgp.ipv6_table_map_filter_variable}}}", null)
  ipv6_table_map_route_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${each.value.bgp.ipv6_table_map_route_policy}"].id, null)
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

resource "sdwan_service_routing_eigrp_feature" "service_routing_eigrp_feature" {
  for_each = {
    for eigrp_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for eigrp in try(profile.eigrp_features, []) : {
          profile = profile
          eigrp   = eigrp
        }
      ]
    ])
    : "${eigrp_item.profile.name}-${eigrp_item.eigrp.name}" => eigrp_item
  }
  name                          = each.value.eigrp.name
  description                   = try(each.value.eigrp.description, null)
  feature_profile_id            = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  autonomous_system_id          = try(each.value.eigrp.autonomous_system_id, null)
  autonomous_system_id_variable = try("{{${each.value.eigrp.autonomous_system_id_variable}}}", null)
  networks = try(length(each.value.eigrp.networks) == 0, true) ? null : [for network in each.value.eigrp.networks : {
    ip_address          = try(network.network_address, null)
    ip_address_variable = try("{{${network.network_address_variable}}}", null)
    mask                = try(network.subnet_mask, null)
    mask_variable       = try("{{${network.subnet_mask_variable}}}", null)
  }]
  authentication_type              = try(each.value.eigrp.authentication_type, null)
  authentication_type_variable     = try("{{${each.value.eigrp.authentication_type_variable}}}", null)
  filter                           = try(each.value.eigrp.filter, null)
  filter_variable                  = try("{{${each.value.eigrp.filter_variable}}}", null)
  hello_interval                   = try(each.value.eigrp.hello_interval, null)
  hello_interval_variable          = try("{{${each.value.eigrp.hello_interval_variable}}}", null)
  hmac_authentication_key          = try(each.value.eigrp.hmac_authentication_key, null)
  hmac_authentication_key_variable = try("{{${each.value.eigrp.hmac_authentication_key_variable}}}", null)
  hold_time                        = try(each.value.eigrp.hold_time, null)
  hold_time_variable               = try("{{${each.value.eigrp.hold_time_variable}}}", null)
  interfaces = try(length(each.value.eigrp.interfaces) == 0, true) ? null : [for interface in each.value.eigrp.interfaces : {
    name              = try(interface.name, null)
    name_variable     = try("{{${interface.name_variable}}}", null)
    shutdown          = try(interface.shutdown, null)
    shutdown_variable = try("{{${interface.shutdown_variable}}}", null)
    summary_addresses = try(length(interface.summary_addresses) == 0, true) ? null : [for summary in interface.summary_addresses : {
      address          = try(summary.network_address, null)
      address_variable = try("{{${summary.network_address_variable}}}", null)
      mask             = try(summary.subnet_mask, null)
      mask_variable    = try("{{${summary.subnet_mask_variable}}}", null)
    }]
  }]
  md5_keys = try(length(each.value.eigrp.md5_keys) == 0, true) ? null : [for key in each.value.eigrp.md5_keys : {
    key_id              = try(key.key_id, null)
    key_id_variable     = try("{{${key.key_id_variable}}}", null)
    key_string          = try(key.key_string, null)
    key_string_variable = try("{{${key.key_string_variable}}}", null)
  }]
  redistributes = try(length(each.value.eigrp.redistributes) == 0, true) ? null : [for redistribute in each.value.eigrp.redistributes : {
    protocol          = try(redistribute.protocol, null)
    protocol_variable = try("{{${redistribute.protocol_variable}}}", null)
    route_policy_id   = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
  }]
  route_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${each.value.eigrp.route_policy}"].id, null)
}

resource "sdwan_service_ipv4_acl_feature" "service_ipv4_acl_feature" {
  for_each = {
    for acl_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for acl in try(profile.ipv4_acls, []) : {
          profile = profile
          acl     = acl
        }
      ]
    ])
    : "${acl_item.profile.name}-${acl_item.acl.name}" => acl_item
  }
  name               = each.value.acl.name
  description        = try(each.value.acl.description, null)
  feature_profile_id = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  default_action     = each.value.acl.default_action
  sequences = try(length(each.value.acl.sequences) == 0, true) ? null : [for s in each.value.acl.sequences : {
    actions = length(keys(try(s.actions, {}))) > 0 ? [{
      accept_counter_name   = s.base_action == "accept" ? try(s.actions.counter_name, null) : null
      accept_log            = s.base_action == "accept" ? try(s.actions.log, null) : null
      accept_mirror_list_id = s.base_action == "accept" && can(s.actions.mirror) ? sdwan_policy_object_mirror.policy_object_mirror[s.actions.mirror].id : null
      accept_policer_id     = s.base_action == "accept" && can(s.actions.policer) ? sdwan_policy_object_policer.policy_object_policer[s.actions.policer].id : null
      accept_set_dscp       = s.base_action == "accept" ? try(s.actions.dscp, null) : null
      accept_set_next_hop   = s.base_action == "accept" ? try(s.actions.ipv4_next_hop, null) : null
      drop_counter_name     = s.base_action == "drop" ? try(s.actions.counter_name, null) : null
      drop_log              = s.base_action == "drop" ? try(s.actions.log, null) : null
    }] : null
    base_action = length(keys(try(s.actions, {}))) > 0 ? null : s.base_action
    match_entries = length(keys(try(s.match_entries, {}))) > 0 ? [{
      destination_data_prefix          = try(s.match_entries.destination_data_prefix, null)
      destination_data_prefix_list_id  = can(s.match_entries.destination_data_prefix_list) ? sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[s.match_entries.destination_data_prefix_list].id : null
      destination_data_prefix_variable = try("{{${s.match_entries.destination_data_prefix_variable}}}", null)
      destination_ports = try(length(s.match_entries.destination_ports) == 0, true) ? null : [for p in s.match_entries.destination_ports : {
        port = p
      }]
      dscps                       = try(s.match_entries.dscps, null)
      icmp_messages               = try(s.match_entries.icmp_messages, null)
      packet_length               = try(s.match_entries.packet_length, null)
      protocols                   = try(s.match_entries.protocols, null)
      source_data_prefix          = try(s.match_entries.source_data_prefix, null)
      source_data_prefix_list_id  = can(s.match_entries.source_data_prefix_list) ? sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[s.match_entries.source_data_prefix_list].id : null
      source_data_prefix_variable = try("{{${s.match_entries.source_data_prefix_variable}}}", null)
      source_ports = try(length(s.match_entries.source_ports) == 0, true) ? null : [for p in s.match_entries.source_ports : {
        port = p
      }]
      tcp_state = try(s.match_entries.tcp_state, null)
    }] : null
    sequence_id   = s.id
    sequence_name = try(s.name, local.defaults.sdwan.feature_profiles.service_profiles.ipv4_acls.sequences.name)
    }
  ]
}

resource "sdwan_service_lan_vpn_feature" "service_lan_vpn_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        }
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}" => lan_vpn_item
  }
  name               = each.value.lan_vpn.name
  description        = try(each.value.lan_vpn.description, null)
  feature_profile_id = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  advertise_omp_ipv4s = try(length(each.value.lan_vpn.ipv4_omp_advertise_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipv4_omp_advertise_routes : {
      protocol          = try(route.protocol, null)
      protocol_variable = try("{{${route.protocol_variable}}}", null)
      route_policy_id   = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${route.route_policy}"].id, null)
      prefixes = try(route.aggregates != null, false) ? [
        for aggregate in route.aggregates : {
          network_address          = try(aggregate.aggregate_address, null)
          network_address_variable = try("{{${aggregate.aggregate_address_variable}}}", null)
          subnet_mask              = try(aggregate.subnet_mask, null)
          subnet_mask_variable     = try("{{${aggregate.subnet_mask_variable}}}", null)
          aggregate_only           = try(aggregate.aggregate_only, null)
          region                   = try(aggregate.region, null)
          region_variable          = try("{{${aggregate.region_variable}}}", null)
        }
        ] : (try(route.networks != null, false) ? [
          for network in route.networks : {
            network_address          = try(network.network_address, null)
            network_address_variable = try("{{${network.network_address_variable}}}", null)
            subnet_mask              = try(network.subnet_mask, null)
            subnet_mask_variable     = try("{{${network.subnet_mask_variable}}}", null)
            region                   = try(network.region, null)
            region_variable          = try("{{${network.region_variable}}}", null)
      }] : null)
    }
  ]
  advertise_omp_ipv6s = try(length(each.value.lan_vpn.ipv6_omp_advertise_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipv6_omp_advertise_routes : {
      protocol = (
        try(route.protocol) == "bgp" ? "BGP" :
        try(route.protocol) == "ospf" ? "OSPF" :
        try(route.protocol) == "connected" ? "Connected" :
        try(route.protocol) == "static" ? "Static" :
        try(route.protocol) == "network" ? "Network" :
        try(route.protocol) == "aggregate" ? "Aggregate" : null
      )
      protocol_variable = try("{{${route.protocol_variable}}}", null)
      route_policy_id   = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${route.route_policy}"].id, null)
      prefixes = try(route.aggregates != null, false) ? [
        for aggregate in route.aggregates : {
          prefix          = try(aggregate.aggregate_prefix, null)
          prefix_variable = try("{{${aggregate.aggregate_prefix_variable}}}", null)
          aggregate_only  = try(aggregate.aggregate_only, null)
          region          = try(aggregate.region, null)
          region_variable = try("{{${aggregate.region_variable}}}", null)
        }
        ] : (try(route.networks != null, false) ? [
          for network in route.networks : {
            prefix          = try(network.prefix, null)
            prefix_variable = try("{{${network.prefix_variable}}}", null)
            region          = try(network.region, null)
            region_variable = try("{{${network.region_variable}}}", null)
      }] : null)
    }
  ]
  config_description          = try(each.value.lan_vpn.vpn_name, null)
  config_description_variable = try("{{${each.value.lan_vpn.vpn_name_variable}}}", null)
  enable_sdwan_remote_access  = try(each.value.lan_vpn.sdwan_remote_access, null)
  # GRE Routes
  gre_routes = try(length(each.value.lan_vpn.gre_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.gre_routes : {
      network_address          = try(route.network_address, null)
      network_address_variable = try("{{${route.network_address_variable}}}", null)
      subnet_mask              = try(route.subnet_mask, null)
      subnet_mask_variable     = try("{{${route.subnet_mask_variable}}}", null)
      interface                = try(route.interfaces, null)
      interfaces_variable      = try("{{${route.interfaces_variable}}}", null)
      vpn                      = 0
    }
  ]
  host_mappings = try(length(each.value.lan_vpn.host_mappings) == 0, true) ? null : [
    for mapping in each.value.lan_vpn.host_mappings : {
      host_name            = try(mapping.hostname, null)
      host_name_variable   = try("{{${mapping.hostname_variable}}}", null)
      list_of_ips          = try(mapping.ips, null)
      list_of_ips_variable = try("{{${mapping.ips_variable}}}", null)
    }
  ]
  ipsec_routes = try(length(each.value.lan_vpn.ipsec_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipsec_routes : {
      network_address          = try(route.network_address, null)
      network_address_variable = try("{{${route.network_address_variable}}}", null)
      subnet_mask              = try(route.subnet_mask, null)
      subnet_mask_variable     = try("{{${route.subnet_mask_variable}}}", null)
      interface                = try(route.interfaces, null)
      interfaces_variable      = try("{{${route.interfaces_variable}}}", null)
    }
  ]
  ipv4_import_route_targets = try(length(each.value.lan_vpn.ipv4_import_route_targets) == 0, true) ? null : [
    for target in each.value.lan_vpn.ipv4_import_route_targets : {
      route_target          = try(target.route_target, null)
      route_target_variable = try("{{${target.route_target_variable}}}", null)
    }
  ]
  ipv4_export_route_targets = try(length(each.value.lan_vpn.ipv4_export_route_targets) == 0, true) ? null : [
    for target in each.value.lan_vpn.ipv4_export_route_targets : {
      route_target          = try(target.route_target, null)
      route_target_variable = try("{{${target.route_target_variable}}}", null)
    }
  ]
  ipv6_import_route_targets = try(length(each.value.lan_vpn.ipv6_import_route_targets) == 0, true) ? null : [
    for target in each.value.lan_vpn.ipv6_import_route_targets : {
      route_target          = try(target.route_target, null)
      route_target_variable = try("{{${target.route_target_variable}}}", null)
    }
  ]
  ipv6_export_route_targets = try(length(each.value.lan_vpn.ipv6_export_route_targets) == 0, true) ? null : [
    for target in each.value.lan_vpn.ipv6_export_route_targets : {
      route_target          = try(target.route_target, null)
      route_target_variable = try("{{${target.route_target_variable}}}", null)
    }
  ]
  ipv4_static_routes = try(length(each.value.lan_vpn.ipv4_static_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipv4_static_routes : {
      network_address          = try(route.network_address, null)
      network_address_variable = try("{{${route.network_address_variable}}}", null)
      subnet_mask              = try(route.subnet_mask, null)
      subnet_mask_variable     = try("{{${route.subnet_mask_variable}}}", null)
      gateway = (
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv4_static_routes.gateway) == "nexthop" ? "nextHop" :
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv4_static_routes.gateway) == "interface" ? "staticRouteInterface" :
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv4_static_routes.gateway)
      )
      dhcp                             = try(route.gateway == "dhcp" ? true : null, null)
      null0                            = try(route.gateway == "null0" ? true : null, null)
      vpn                              = try(route.gateway == "vpn" ? true : null, null)
      administrative_distance          = try(route.gateway == "null0" ? route.administrative_distance : null, null)
      administrative_distance_variable = try(route.gateway == "null0" ? "{{${route.administrative_distance_variable}}}" : null, null)
      next_hops = try(length(route.next_hops) == 0, true) ? null : [
        for nh in route.next_hops : {
          address                          = try(nh.address, null)
          address_variable                 = try("{{${nh.address_variable}}}", null)
          administrative_distance          = try(nh.administrative_distance, null)
          administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
        }
      ],
      next_hop_with_trackers = try(length(route.next_hops_with_tracker) == 0, true) ? null : [
        for nh in route.next_hops_with_tracker : {
          address                          = try(nh.address, null)
          address_variable                 = try("{{${nh.address_variable}}}", null)
          administrative_distance          = try(nh.administrative_distance, null)
          administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
          tracker_id = try(
            sdwan_service_tracker_feature.service_tracker_feature["${each.value.profile.name}-${nh.tracker}"].id,
            try(
              sdwan_service_tracker_group_feature.service_tracker_group_feature["${each.value.profile.name}-${nh.tracker}"].id,
              null
            )
          )
        }
      ],
      ip_static_route_interface = try(route.static_route_interface, null) != null ? [{
        interface_name          = try(route.static_route_interface.interface_name, null)
        interface_name_variable = try("{{${route.static_route_interface.interface_name_variable}}}", null)
        next_hop = try(length(route.static_route_interface.next_hops) == 0, true) ? null : [
          for nh in route.static_route_interface.next_hops : {
            address                          = try(nh.address, null)
            address_variable                 = try("{{${nh.address_variable}}}", null)
            administrative_distance          = try(nh.administrative_distance, null)
            administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
          }
        ]
      }] : null
    }
  ]
  ipv6_static_routes = try(length(each.value.lan_vpn.ipv6_static_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipv6_static_routes : {
      prefix          = try(route.prefix, null)
      prefix_variable = try("{{${route.prefix_variable}}}", null)
      gateway = (
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv6_static_routes.gateway) == "nexthop" ? "nextHop" :
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv6_static_routes.gateway) == "interface" ? "staticRouteInterface" :
        try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv6_static_routes.gateway)
      )
      nat          = try(route.gateway == "nat" ? upper(route.nat) : null, null)
      nat_variable = try(route.gateway == "nat" ? "{{${route.nat_variable}}}" : null, null)
      null0        = try(route.gateway == "null0" ? true : null, null)
      next_hops = try(length(route.next_hops) == 0, true) ? null : [
        for nh in route.next_hops : {
          address                          = try(nh.address, null)
          address_variable                 = try("{{${nh.address_variable}}}", null)
          administrative_distance          = try(nh.administrative_distance, null)
          administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
        }
      ],
      ipv6_static_route_interface = try(route.static_route_interface, null) != null ? [{
        interface_name          = try(route.static_route_interface.interface_name, null)
        interface_name_variable = try("{{${route.static_route_interface.interface_name_variable}}}", null)
        next_hop = try(length(route.static_route_interface.next_hops) == 0, true) ? null : [
          for nh in route.static_route_interface.next_hops : {
            address                          = try(nh.address, null)
            address_variable                 = try("{{${nh.address_variable}}}", null)
            administrative_distance          = try(nh.administrative_distance, null)
            administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
          }
        ]
      }] : null
    }
  ]
  nat_pools = try(length(each.value.lan_vpn.nat_pools) == 0, true) ? null : [
    for pool in each.value.lan_vpn.nat_pools : {
      nat_pool_name          = try(pool.id, null)
      nat_pool_name_variable = try("{{${pool.id_variable}}}", null)
      direction              = try(pool.direction, null)
      direction_variable     = try("{{${pool.direction_variable}}}", null)
      overload               = try(pool.overload, null)
      overload_variable      = try("{{${pool.overload_variable}}}", null)
      prefix_length          = try(pool.prefix_length, null)
      prefix_length_variable = try("{{${pool.prefix_length_variable}}}", null)
      range_start            = try(pool.range_start, null)
      range_start_variable   = try("{{${pool.range_start_variable}}}", null)
      range_end              = try(pool.range_end, null)
      range_end_variable     = try("{{${pool.range_end_variable}}}", null)
      tracker_object_id = try(sdwan_service_object_tracker_feature.service_object_tracker_feature["${each.value.profile.name}-${pool.tracker_object}"].id,
      try(sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${each.value.profile.name}-${pool.tracker_object}"].id, null))
    }
  ]
  nat_port_forwards = try(length(each.value.lan_vpn.nat_port_forwards) == 0, true) ? null : [
    for forward in each.value.lan_vpn.nat_port_forwards : {
      nat_pool_name                 = try(forward.nat_pool_id, null)
      nat_pool_name_variable        = try("{{${forward.nat_pool_id_variable}}}", null)
      protocol                      = try(upper(forward.protocol), null)
      protocol_variable             = try("{{${forward.protocol_variable}}}", null)
      source_ip                     = try(forward.source_ip, null)
      source_ip_variable            = try("{{${forward.source_ip_variable}}}", null)
      source_port                   = try(forward.source_port, null)
      source_port_variable          = try("{{${forward.source_port_variable}}}", null)
      translated_source_ip          = try(forward.translate_ip, null)
      translated_source_ip_variable = try("{{${forward.translate_ip_variable}}}", null)
      translate_port                = try(forward.translate_port, null)
      translate_port_variable       = try("{{${forward.translate_port_variable}}}", null)
    }
  ]
  nat_64_v4_pools = try(length(each.value.lan_vpn.nat64_pools) == 0, true) ? null : [
    for pool in each.value.lan_vpn.nat64_pools : {
      name                 = try(pool.name, null)
      name_variable        = try("{{${pool.name_variable}}}", null)
      range_start          = try(pool.range_start, null)
      range_start_variable = try("{{${pool.range_start_variable}}}", null)
      range_end            = try(pool.range_end, null)
      range_end_variable   = try("{{${pool.range_end_variable}}}", null)
      overload             = try(pool.overload, null)
      overload_variable    = try("{{${pool.overload_variable}}}", null)
    }
  ]
  omp_admin_distance_ipv4           = try(each.value.lan_vpn.ipv4_omp_admin_distance, null)
  omp_admin_distance_ipv4_variable  = try("{{${each.value.lan_vpn.ipv4_omp_admin_distance_variable}}}", null)
  omp_admin_distance_ipv6           = try(each.value.lan_vpn.ipv6_omp_admin_distance, null)
  omp_admin_distance_ipv6_variable  = try("{{${each.value.lan_vpn.ipv6_omp_admin_distance_variable}}}", null)
  primary_dns_address_ipv4          = try(each.value.lan_vpn.ipv4_primary_dns_address, null)
  primary_dns_address_ipv4_variable = try("{{${each.value.lan_vpn.ipv4_primary_dns_address_variable}}}", null)
  primary_dns_address_ipv6          = try(each.value.lan_vpn.ipv6_primary_dns_address, null)
  primary_dns_address_ipv6_variable = try("{{${each.value.lan_vpn.ipv6_primary_dns_address_variable}}}", null)
  route_leak_from_global_vpns = try(length(each.value.lan_vpn.route_leaks_from_global) == 0, true) ? null : [
    for leak in each.value.lan_vpn.route_leaks_from_global : {
      route_protocol          = try(leak.protocol, null)
      route_protocol_variable = try("{{${leak.protocol_variable}}}", null)
      route_policy_id         = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${leak.route_policy}"].id, null)
      redistributions = try(length(leak.redistributions) == 0, true) ? null : [
        for rd in leak.redistributions : {
          protocol                 = try(rd.protocol, null)
          protocol_variable        = try("{{${rd.protocol_variable}}}", null)
          redistribution_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${rd.route_policy}"].id, null)
        }
      ]
    }
  ]
  route_leak_to_global_vpns = try(length(each.value.lan_vpn.route_leaks_to_global) == 0, true) ? null : [
    for leak in each.value.lan_vpn.route_leaks_to_global : {
      route_protocol          = try(leak.protocol, null)
      route_protocol_variable = try("{{${leak.protocol_variable}}}", null)
      route_policy_id         = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${leak.route_policy}"].id, null)
      redistributions = try(length(leak.redistributions) == 0, true) ? null : [
        for rd in leak.redistributions : {
          protocol                 = try(rd.protocol, null)
          protocol_variable        = try("{{${rd.protocol_variable}}}", null)
          redistribution_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${rd.route_policy}"].id, null)
        }
      ]
    }
  ]
  route_leak_from_other_services = try(length(each.value.lan_vpn.route_leaks_from_service) == 0, true) ? null : [
    for leak in each.value.lan_vpn.route_leaks_from_service : {
      source_vpn              = try(leak.source_vpn, null)
      source_vpn_variable     = try("{{${leak.source_vpn_variable}}}", null)
      route_protocol          = try(leak.protocol, null)
      route_protocol_variable = try("{{${leak.protocol_variable}}}", null)
      route_policy_id         = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${leak.route_policy}"].id, null)
      redistributions = try(length(leak.redistributions) == 0, true) ? null : [
        for rd in leak.redistributions : {
          protocol                 = try(rd.protocol, null)
          protocol_variable        = try("{{${rd.protocol_variable}}}", null)
          redistribution_policy_id = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${rd.route_policy}"].id, null)
        }
      ]
    }
  ]
  secondary_dns_address_ipv4          = try(each.value.lan_vpn.ipv4_secondary_dns_address, null)
  secondary_dns_address_ipv4_variable = try("{{${each.value.lan_vpn.ipv4_secondary_dns_address_variable}}}", null)
  secondary_dns_address_ipv6          = try(each.value.lan_vpn.ipv6_secondary_dns_address, null)
  secondary_dns_address_ipv6_variable = try("{{${each.value.lan_vpn.ipv6_secondary_dns_address_variable}}}", null)
  # Service Routes
  service_routes = try(length(each.value.lan_vpn.service_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.service_routes : {
      network_address          = try(route.network_address, null)
      network_address_variable = try("{{${route.network_address_variable}}}", null)
      subnet_mask              = try(route.subnet_mask, null)
      subnet_mask_variable     = try("{{${route.subnet_mask_variable}}}", null)
      service                  = try(upper(route.service), null)
      service_variable         = try("{{${route.service_variable}}}", null)
      vpn                      = 0
      sse_instance = (
        try(route.sse_instance, null) == "cisco-secure-access" ? "Cisco-Secure-Access" :
        try(route.sse_instance, null) == "zscaler" ? "zScaler" :
        null
      )
      sse_instance_variable = try("{{${route.sse_instance_variable}}}", null)
    }
  ]
  # Services
  services = try(length(each.value.lan_vpn.services) == 0, true) ? null : [
    for service in each.value.lan_vpn.services : {
      service_type = (
        try(service.service_type) == "fw" ? "FW" :
        try(service.service_type) == "ids" ? "IDS" :
        try(service.service_type) == "idp" ? "IDP" :
        try(service.service_type) == "te" ? "TE" :
        try(service.service_type, null)
      )
      service_type_variable   = try("{{${service.service_type_variable}}}", null)
      ipv4_addresses          = try(service.ipv4_addresses, null)
      ipv4_addresses_variable = try("{{${service.ipv4_addresses_variable}}}", null)
      tracking                = try(service.track_enable, null)
      tracking_variable       = try("{{${service.track_enable_variable}}}", null)
    }
  ]
  static_nats = try(length(each.value.lan_vpn.static_nat_entries) == 0, true) ? null : [
    for nat in each.value.lan_vpn.static_nat_entries : {
      nat_pool_name                 = try(nat.nat_pool_id, null)
      source_ip                     = try(nat.source_ip, null)
      source_ip_variable            = try("{{${nat.source_ip_variable}}}", null)
      translated_source_ip          = try(nat.translate_ip, null)
      translated_source_ip_variable = try("{{${nat.translate_ip_variable}}}", null)
      static_nat_direction          = try(nat.direction, null)
      tracker_object_id = try(sdwan_service_object_tracker_feature.service_object_tracker_feature["${each.value.profile.name}-${nat.tracker_object}"].id,
      try(sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${each.value.profile.name}-${nat.tracker_object}"].id, null))
    }
  ]
  static_nat_subnets = try(length(each.value.lan_vpn.static_nat_subnets) == 0, true) ? null : [
    for subnet in each.value.lan_vpn.static_nat_subnets : {
      source_ip_subnet                     = try(subnet.source_ip_subnet, null)
      source_ip_subnet_variable            = try("{{${subnet.source_ip_subnet_variable}}}", null)
      translated_source_ip_subnet          = try(subnet.translated_source_ip_subnet, null)
      translated_source_ip_subnet_variable = try("{{${subnet.translated_source_ip_subnet_variable}}}", null)
      prefix_length                        = try(subnet.prefix_length, null)
      prefix_length_variable               = try("{{${subnet.prefix_length_variable}}}", null)
      static_nat_direction                 = try(subnet.direction, null)
      static_nat_direction_variable        = try("{{${subnet.direction_variable}}}", null)
      tracker_object_id = try(sdwan_service_object_tracker_feature.service_object_tracker_feature["${each.value.profile.name}-${subnet.tracker_object}"].id,
      try(sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${each.value.profile.name}-${subnet.tracker_object}"].id, null))
    }
  ]
  vpn          = try(each.value.lan_vpn.vpn_id, null)
  vpn_variable = try("{{${each.value.lan_vpn.vpn_id_variable}}}", null)
}

resource "sdwan_service_lan_vpn_feature_associate_routing_bgp_feature" "service_lan_vpn_feature_associate_routing_bgp_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        } if try(lan_vpn.bgp, null) != null
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}-routing_bgp" => lan_vpn_item
  }
  feature_profile_id             = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id     = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_routing_bgp_feature_id = sdwan_service_routing_bgp_feature.service_routing_bgp_feature["${each.value.profile.name}-${each.value.lan_vpn.bgp}"].id
}

resource "sdwan_service_lan_vpn_feature_associate_routing_eigrp_feature" "service_lan_vpn_feature_associate_routing_eigrp_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        } if try(lan_vpn.eigrp, null) != null
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}-routing_eigrp" => lan_vpn_item
  }
  feature_profile_id               = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id       = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_routing_eigrp_feature_id = sdwan_service_routing_eigrp_feature.service_routing_eigrp_feature["${each.value.profile.name}-${each.value.lan_vpn.eigrp}"].id
}

resource "sdwan_service_lan_vpn_feature_associate_multicast_feature" "service_lan_vpn_feature_associate_multicast_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        } if try(lan_vpn.multicast, null) != null
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}-routing_multicast" => lan_vpn_item
  }
  feature_profile_id           = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id   = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_multicast_feature_id = sdwan_service_multicast_feature.service_multicast_feature["${each.value.profile.name}-${each.value.lan_vpn.multicast}"].id
}

resource "sdwan_service_lan_vpn_feature_associate_routing_ospf_feature" "service_lan_vpn_feature_associate_routing_ospf_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        } if try(lan_vpn.ospf, null) != null
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}-routing_ospf" => lan_vpn_item
  }
  feature_profile_id              = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id      = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_routing_ospf_feature_id = sdwan_service_routing_ospf_feature.service_routing_ospf_feature["${each.value.profile.name}-${each.value.lan_vpn.ospf}"].id
}

resource "sdwan_service_lan_vpn_feature_associate_routing_ospfv3_ipv6_feature" "service_lan_vpn_feature_associate_routing_ospfv3_ipv6_feature" {
  for_each = {
    for lan_vpn_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for lan_vpn in try(profile.lan_vpns, []) : {
          profile = profile
          lan_vpn = lan_vpn
        } if try(lan_vpn.ospfv3_ipv6, null) != null
      ]
    ])
    : "${lan_vpn_item.profile.name}-${lan_vpn_item.lan_vpn.name}-routing_ospfv3_ipv6" => lan_vpn_item
  }
  feature_profile_id                     = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id             = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_routing_ospfv3_ipv6_feature_id = sdwan_service_routing_ospfv3_ipv6_feature.service_routing_ospfv3_ipv6_feature["${each.value.profile.name}-${each.value.lan_vpn.ospfv3_ipv6}"].id
}

resource "sdwan_service_lan_vpn_interface_ethernet_feature" "service_lan_vpn_interface_ethernet_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, {}) : [
        for lan_vpn in try(profile.lan_vpns, []) : [
          for interface in try(lan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            lan_vpn   = lan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-${interface_item.lan_vpn.name}-${interface_item.interface.name}" => interface_item
  }
  name                       = each.value.interface.name
  description                = try(each.value.interface.description, null)
  feature_profile_id         = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  acl_ipv4_egress_policy_id  = try(sdwan_service_ipv4_acl_feature.service_ipv4_acl_feature["${each.value.profile.name}-${each.value.interface.ipv4_egress_acl}"].id, null)
  acl_ipv4_ingress_policy_id = try(sdwan_service_ipv4_acl_feature.service_ipv4_acl_feature["${each.value.profile.name}-${each.value.interface.ipv4_ingress_acl}"].id, null)
  acl_ipv6_egress_policy_id  = try(sdwan_service_ipv6_acl_feature.service_ipv6_acl_feature["${each.value.profile.name}-${each.value.interface.ipv6_egress_acl}"].id, null)
  acl_ipv6_ingress_policy_id = try(sdwan_service_ipv6_acl_feature.service_ipv6_acl_feature["${each.value.profile.name}-${each.value.interface.ipv6_ingress_acl}"].id, null)
  acl_shaping_rate           = try(each.value.interface.shaping_rate, null)
  acl_shaping_rate_variable  = try("{{${each.value.interface.shaping_rate_variable}}}", null)
  arp_timeout                = try(each.value.interface.arp_timeout, null)
  arp_timeout_variable       = try("{{${each.value.interface.arp_timeout_variable}}}", null)
  arps = try(length(each.value.interface.arp_entries) == 0, true) ? null : [for arp in each.value.interface.arp_entries : {
    ip_address           = try(arp.ip_address, null)
    ip_address_variable  = try("{{${arp.ip_address_variable}}}", null)
    mac_address          = try(arp.mac_address, null)
    mac_address_variable = try("{{${arp.mac_address_variable}}}", null)
  }]
  autonegotiate                  = try(each.value.interface.autonegotiate, null)
  autonegotiate_variable         = try("{{${each.value.interface.autonegotiate_variable}}}", null)
  duplex                         = try(each.value.interface.duplex, null)
  duplex_variable                = try("{{${each.value.interface.duplex_variable}}}", null)
  enable_dhcpv6                  = try(each.value.interface.ipv6_configuration_type, null) == "dynamic" ? true : null
  icmp_redirect_disable          = try(each.value.interface.icmp_redirect_disable, null)
  icmp_redirect_disable_variable = try("{{${each.value.interface.icmp_redirect_disable_variable}}}", null)
  interface_description          = try(each.value.interface.interface_description, null)
  interface_description_variable = try("{{${each.value.interface.interface_description_variable}}}", null)
  interface_mtu                  = try(each.value.interface.interface_mtu, null)
  interface_mtu_variable         = try("{{${each.value.interface.interface_mtu_variable}}}", null)
  interface_name                 = try(each.value.interface.interface_name, null)
  interface_name_variable        = try("{{${each.value.interface.interface_name_variable}}}", null)
  ip_directed_broadcast          = try(each.value.interface.ip_directed_broadcast, null)
  ip_directed_broadcast_variable = try("{{${each.value.interface.ip_directed_broadcast_variable}}}", null)
  ip_mtu                         = try(each.value.interface.ip_mtu, null)
  ip_mtu_variable                = try("{{${each.value.interface.ip_mtu_variable}}}", null)
  ipv4_address                   = try(each.value.interface.ipv4_address, null)
  ipv4_address_variable          = try("{{${each.value.interface.ipv4_address_variable}}}", null)
  ipv4_configuration_type        = try(each.value.interface.ipv4_configuration_type, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ethernet_interfaces.ipv4_configuration_type)
  ipv4_dhcp_distance             = try(each.value.interface.ipv4_dhcp_distance, null)
  ipv4_dhcp_distance_variable    = try("{{${each.value.interface.ipv4_dhcp_distance_variable}}}", null)
  ipv4_dhcp_helper               = try(each.value.interface.ipv4_dhcp_helpers, null)
  ipv4_dhcp_helper_variable      = try("{{${each.value.interface.ipv4_dhcp_helpers_variable}}}", null)
  ipv4_secondary_addresses = try(length(each.value.interface.ipv4_secondary_addresses) == 0, true) ? null : [for a in each.value.interface.ipv4_secondary_addresses : {
    address              = try(a.address, null)
    address_variable     = try("{{${a.address_variable}}}", null)
    subnet_mask          = try(a.subnet_mask, null)
    subnet_mask_variable = try("{{${a.subnet_mask_variable}}}", null)
  }]
  ipv4_subnet_mask          = try(each.value.interface.ipv4_subnet_mask, null)
  ipv4_subnet_mask_variable = try("{{${each.value.interface.ipv4_subnet_mask_variable}}}", null)
  ipv4_vrrps = try(length(each.value.interface.ipv4_vrrp_groups) == 0, true) ? null : [for vrrp in each.value.interface.ipv4_vrrp_groups : {
    address                = try(vrrp.address, null)
    address_variable       = try("{{${vrrp.address_variable}}}", null)
    group_id               = try(vrrp.id, null)
    group_id_variable      = try("{{${vrrp.id_variable}}}", null)
    priority               = try(vrrp.priority, null)
    priority_variable      = try("{{${vrrp.priority_variable}}}", null)
    timer                  = try(vrrp.timer, null)
    timer_variable         = try("{{${vrrp.timer_variable}}}", null)
    tloc_prefix_change     = try(vrrp.tloc_preference_change, null)
    tloc_pref_change_value = try(vrrp.tloc_preference_change_value, null)
    track_omp              = try(vrrp.track_omp, null)
    secondary_addresses = try(length(vrrp.secondary_addresses) == 0, true) ? null : [for addr in vrrp.secondary_addresses : {
      address              = try(addr.address, null)
      address_variable     = try("{{${addr.address_variable}}}", null)
      subnet_mask          = try(addr.subnet_mask, null)
      subnet_mask_variable = try("{{${addr.subnet_mask_variable}}}", null)
    }]
    tracking_objects = try(length(vrrp.tracking_objects) == 0, true) ? null : [for obj in vrrp.tracking_objects : {
      tracker_id = try(
        sdwan_service_object_tracker_feature.service_object_tracker_feature["${each.value.profile.name}-${obj.tracker_object}"].id,
        try(
          sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${each.value.profile.name}-${obj.tracker_object}"].id,
          null
        )
      )
      tracker_action           = try(obj.action == "shutdown" ? "Shutdown" : try(obj.action == "decrement" ? "Decrement" : null), null)
      tracker_action_variable  = try("{{${obj.action_variable}}}", null)
      decrement_value          = try(obj.decrement_value, null)
      decrement_value_variable = try("{{${obj.decrement_value_variable}}}", null)
    }]
  }]
  ipv6_address            = try(each.value.interface.ipv6_address, null)
  ipv6_address_variable   = try("{{${each.value.interface.ipv6_address_variable}}}", null)
  ipv6_configuration_type = try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ethernet_interfaces.ipv6_configuration_type) == "none" ? null : try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ethernet_interfaces.ipv6_configuration_type)
  ipv6_dhcp_helpers = try(length(each.value.interface.ipv6_dhcp_helpers) == 0, true) ? null : [for helper in each.value.interface.ipv6_dhcp_helpers : {
    address                    = try(helper.address, null)
    address_variable           = try("{{${helper.address_variable}}}", null)
    dhcpv6_helper_vpn          = try(helper.vpn_id, null)
    dhcpv6_helper_vpn_variable = try("{{${helper.vpn_id_variable}}}", null)
  }]
  ipv6_dhcp_secondary_addresses = try(length(each.value.interface.ipv6_dhcp_secondary_addresses) == 0, true) ? null : [for addr in each.value.interface.ipv6_dhcp_secondary_addresses : {
    address          = try(addr.address, null)
    address_variable = try("{{${addr.address_variable}}}", null)
  }]
  ipv6_secondary_addresses = try(length(each.value.interface.ipv6_secondary_addresses) == 0, true) ? null : [for addr in each.value.interface.ipv6_secondary_addresses : {
    address          = try(addr.address, null)
    address_variable = try("{{${addr.address_variable}}}", null)
  }]
  ipv6_vrrps = try(length(each.value.interface.ipv6_vrrp_groups) == 0, true) ? null : [for vrrp in each.value.interface.ipv6_vrrp_groups : {
    group_id          = try(vrrp.id, null)
    group_id_variable = try("{{${vrrp.id_variable}}}", null)
    priority          = try(vrrp.priority, null)
    priority_variable = try("{{${vrrp.priority_variable}}}", null)
    timer             = try(vrrp.timer, null)
    timer_variable    = try("{{${vrrp.timer_variable}}}", null)
    track_omp         = try(vrrp.track_omp, null)
    ipv6_addresses = try(vrrp.link_local_address, null) != null || try(vrrp.link_local_address_variable, null) != null || try(vrrp.global_prefix, null) != null || try(vrrp.global_prefix_variable, null) != null ? [{
      link_local_address          = try(vrrp.link_local_address, null)
      link_local_address_variable = try("{{${vrrp.link_local_address_variable}}}", null)
      global_address              = try(vrrp.global_prefix, null)
      global_address_variable     = try("{{${vrrp.global_prefix_variable}}}", null)
    }] : null
  }]
  load_interval                                 = try(each.value.interface.load_interval, null)
  load_interval_variable                        = try("{{${each.value.interface.load_interval_variable}}}", null)
  mac_address                                   = try(each.value.interface.mac_address, null)
  mac_address_variable                          = try("{{${each.value.interface.mac_address_variable}}}", null)
  media_type                                    = try(each.value.interface.media_type, null)
  media_type_variable                           = try("{{${each.value.interface.media_type_variable}}}", null)
  shutdown                                      = try(each.value.interface.shutdown, null)
  shutdown_variable                             = try("{{${each.value.interface.shutdown_variable}}}", null)
  speed                                         = try(each.value.interface.speed, null)
  speed_variable                                = try("{{${each.value.interface.speed_variable}}}", null)
  tcp_mss                                       = try(each.value.interface.tcp_mss, null)
  tcp_mss_variable                              = try("{{${each.value.interface.tcp_mss_variable}}}", null)
  trustsec_enable_enforced_propogation          = try(each.value.interface.trustsec_enable_enforced_propogation, null)
  trustsec_enable_sgt_propogation               = try(each.value.interface.trustsec_enable_sgt_propogation, null)
  trustsec_enforced_security_group_tag          = try(each.value.interface.trustsec_enforced_sgt, null)
  trustsec_enforced_security_group_tag_variable = try("{{${each.value.interface.trustsec_enforced_sgt_variable}}}", null)
  trustsec_propogate                            = try(each.value.interface.trustsec_propogate, null)
  trustsec_security_group_tag                   = try(each.value.interface.trustsec_sgt, null)
  trustsec_security_group_tag_variable          = try("{{${each.value.interface.trustsec_sgt_variable}}}", null)
  xconnect                                      = try(each.value.interface.xconnect, null)
  xconnect_variable                             = try("{{${each.value.interface.xconnect_variable}}}", null)
}

resource "sdwan_service_lan_vpn_interface_ethernet_feature_associate_dhcp_server_feature" "service_lan_vpn_interface_ethernet_feature_associate_dhcp_server_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, {}) : [
        for lan_vpn in try(profile.lan_vpns, []) : [
          for interface in try(lan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            lan_vpn   = lan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-${interface_item.lan_vpn.name}-${interface_item.interface.name}-dhcp_server" => interface_item
    if try(interface_item.interface.dhcp_server, null) != null
  }
  feature_profile_id                            = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id                    = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_lan_vpn_interface_ethernet_feature_id = sdwan_service_lan_vpn_interface_ethernet_feature.service_lan_vpn_interface_ethernet_feature["${each.value.profile.name}-${each.value.lan_vpn.name}-${each.value.interface.name}"].id
  service_dhcp_server_feature_id                = sdwan_service_dhcp_server_feature.service_dhcp_server_feature["${each.value.profile.name}-${each.value.interface.dhcp_server}"].id
}

resource "sdwan_service_lan_vpn_interface_ethernet_feature_associate_tracker_feature" "service_lan_vpn_interface_ethernet_feature_associate_tracker_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, {}) : [
        for lan_vpn in try(profile.lan_vpns, []) : [
          for interface in try(lan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            lan_vpn   = lan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-${interface_item.lan_vpn.name}-${interface_item.interface.name}-tracker" => interface_item
    if try(interface_item.interface.ipv4_tracker, null) != null
  }
  feature_profile_id                            = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id                    = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_lan_vpn_interface_ethernet_feature_id = sdwan_service_lan_vpn_interface_ethernet_feature.service_lan_vpn_interface_ethernet_feature["${each.value.profile.name}-${each.value.lan_vpn.name}-${each.value.interface.name}"].id
  service_tracker_feature_id                    = sdwan_service_tracker_feature.service_tracker_feature["${each.value.profile.name}-${each.value.interface.ipv4_tracker}"].id
}

resource "sdwan_service_lan_vpn_interface_ethernet_feature_associate_tracker_group_feature" "service_lan_vpn_interface_ethernet_feature_associate_tracker_group_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, {}) : [
        for lan_vpn in try(profile.lan_vpns, []) : [
          for interface in try(lan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            lan_vpn   = lan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-${interface_item.lan_vpn.name}-${interface_item.interface.name}-trackergroup" => interface_item
    if try(interface_item.interface.ipv4_tracker_group, null) != null
  }
  feature_profile_id                            = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  service_lan_vpn_feature_id                    = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${each.value.profile.name}-${each.value.lan_vpn.name}"].id
  service_lan_vpn_interface_ethernet_feature_id = sdwan_service_lan_vpn_interface_ethernet_feature.service_lan_vpn_interface_ethernet_feature["${each.value.profile.name}-${each.value.lan_vpn.name}-${each.value.interface.name}"].id
  service_tracker_group_feature_id              = sdwan_service_tracker_group_feature.service_tracker_group_feature["${each.value.profile.name}-${each.value.interface.ipv4_tracker_group}"].id
}

resource "sdwan_service_multicast_feature" "service_multicast_feature" {
  for_each = {
    for multicast_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for multicast in try(profile.multicast_features, []) : {
          profile   = profile
          multicast = multicast
        }
      ]
    ])
    : "${multicast_item.profile.name}-${multicast_item.multicast.name}" => multicast_item
  }
  name                                 = each.value.multicast.name
  description                          = try(each.value.multicast.description, null)
  feature_profile_id                   = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  pim_source_specific_multicast_enable = each.value.multicast.pim_source_specific_multicast
  auto_rp_announces = try(length(each.value.multicast.auto_rp_announces) == 0, true) ? null : [for auto_rp_announce in each.value.multicast.auto_rp_announces : {
    interface_name          = try(auto_rp_announce.interface_name, null)
    interface_name_variable = try("{{${auto_rp_announce.interface_name_variable}}}", null)
    scope                   = try(auto_rp_announce.scope, null)
    scope_variable          = try("{{${auto_rp_announce.scope_variable}}}", null)
  }]
  auto_rp_discoveries = try(length(each.value.multicast.auto_rp_discoveries) == 0, true) ? null : [for auto_rp_discovery in each.value.multicast.auto_rp_discoveries : {
    interface_name          = try(auto_rp_discovery.interface_name, null)
    interface_name_variable = try("{{${auto_rp_discovery.interface_name_variable}}}", null)
    scope                   = try(auto_rp_discovery.scope, null)
    scope_variable          = try("{{${auto_rp_discovery.scope_variable}}}", null)
  }]
  enable_auto_rp          = try(each.value.multicast.auto_rp, null)
  enable_auto_rp_variable = try("{{${each.value.multicast.auto_rp_variable}}}", null)
  igmp_interfaces = try(length(each.value.multicast.igmp_interfaces) == 0, true) ? null : [for igmp_interface in each.value.multicast.igmp_interfaces : {
    interface_name          = try(igmp_interface.interface_name, null)
    interface_name_variable = try("{{${igmp_interface.interface_name_variable}}}", null)
    join_groups = try(length(igmp_interface.join_groups) == 0, true) ? null : [for join_group in igmp_interface.join_groups : {
      group_address           = try(join_group.group_address, null)
      group_address_variable  = try("{{${join_group.group_address_variable}}}", null)
      source_address          = try(join_group.source_address, null)
      source_address_variable = try("{{${join_group.source_address_variable}}}", null)
    }]
    version          = try(igmp_interface.version, null)
    version_variable = try("{{${igmp_interface.version_variable}}}", null)
  }]
  local_replicator                        = try(each.value.multicast.local_replicator, null)
  local_replicator_variable               = try(each.value.multicast.local_replicator_variable, null)
  local_replicator_threshold              = try(each.value.multicast.threshold, null)
  local_replicator_threshold_variable     = try(each.value.multicast.threshold_variable, null)
  msdp_connection_retry_interval          = try(each.value.multicast.msdp_connection_retry_interval, null)
  msdp_connection_retry_interval_variable = try("{{${each.value.multicast.msdp_connection_retry_interval_variable}}}", null)
  msdp_groups = try(length(each.value.multicast.msdp_mesh_groups) == 0, true) ? null : [for msdp_group in each.value.multicast.msdp_mesh_groups : {
    mesh_group_name          = try(msdp_group.name, null)
    mesh_group_name_variable = try("{{${msdp_group.name_variable}}}", null)
    peers = try(length(msdp_group.peers) == 0, true) ? null : [for peer in msdp_group.peers : {
      connection_source_interface           = try(peer.connection_source_interface, null)
      connection_source_interface_variable  = try("{{${peer.connection_source_interface_variable}}}", null)
      default_peer                          = try(peer.default_peer, null)
      keepalive_hold_time                   = try(peer.keepalive_hold_time, null)
      keepalive_hold_time_variable          = try("{{${peer.keepalive_hold_time_variable}}}}", null)
      keepalive_interval                    = try(peer.keepalive_interval, null)
      keepalive_interval_variable           = try("{{${peer.keepalive_interval_variable}}}", null)
      peer_authentication_password          = try(peer.peer_authentication_password, null)
      peer_authentication_password_variable = try("{{${peer.peer_authentication_password_variable}}}", null)
      peer_ip                               = try(peer.peer_ip, null)
      peer_ip_variable                      = try("{{${peer.peer_ip_variable}}}", null)
      prefix_list_id                        = try(sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[peer.prefix_list].id, null)
      remote_as                             = try(peer.remote_as, null)
      remote_as_variable                    = try("{{${peer.remote_as_variable}}}", null)
      sa_limit                              = try(peer.sa_limit, null)
      sa_limit_variable                     = try("{{${peer.sa_limit_variable}}}", null)
    }]
  }]
  msdp_originator_id          = try(each.value.multicast.msdp_originator_id, null)
  msdp_originator_id_variable = try("{{${each.value.multicast.msdp_originator_id_variable}}}", null)
  pim_bsr_candidates = try(length(each.value.multicast.pim_bsr_candidates) == 0, true) ? null : [for bsr_candidate in each.value.multicast.pim_bsr_candidates : {
    interface_name                        = try(bsr_candidate.interface_name, null)
    interface_name_variable               = try("{{${bsr_candidate.interface_name_variable}}}", null)
    accept_candidate_access_list          = try(bsr_candidate.accept_candidate_access_list, null)
    accept_candidate_access_list_variable = try("{{${bsr_candidate.accept_candidate_access_list_variable}}}", null)
    hash_mask_length                      = try(bsr_candidate.hash_mask_length, null)
    hash_mask_length_variable             = try("{{${bsr_candidate.hash_mask_length_variable}}}", null)
    priority                              = try(bsr_candidate.priority, null)
    priority_variable                     = try("{{${bsr_candidate.priority_variable}}}", null)
  }]
  pim_bsr_rp_candidates = try(length(each.value.multicast.pim_bsr_rp_candidates) == 0, true) ? null : [for bsr_rp_candidate in each.value.multicast.pim_bsr_rp_candidates : {
    interface_name          = try(bsr_rp_candidate.interface_name, null)
    interface_name_variable = try("{{${bsr_rp_candidate.interface_name_variable}}}", null)
    access_list_id          = try(bsr_rp_candidate.access_list, null)
    access_list_id_variable = try("{{${bsr_rp_candidate.access_list_id_variable}}}", null)
    interval                = try(bsr_rp_candidate.interval, null)
    interval_variable       = try("{{${bsr_rp_candidate.interval_variable}}}", null)
    priority                = try(bsr_rp_candidate.priority, null)
    priority_variable       = try("{{${bsr_rp_candidate.priority_variable}}}", null)
  }]
  pim_interfaces = try(length(each.value.multicast.pim_interfaces) == 0, true) ? null : [for pim_interface in each.value.multicast.pim_interfaces : {
    interface_name               = try(pim_interface.interface_name, null)
    interface_name_variable      = try("{{${pim_interface.interface_name_variable}}}", null)
    join_prune_interval          = try(pim_interface.join_prune_interval, null)
    join_prune_interval_variable = try("{{${pim_interface.join_prune_interval_variable}}}", null)
    query_interval               = try(pim_interface.query_interval, null)
    query_interval_variable      = try("{{${pim_interface.query_interval_variable}}}", null)
  }]
  pim_source_specific_multicast_access_list          = try(each.value.multicast.pim_source_specific_multicast_access_list, null)
  pim_source_specific_multicast_access_list_variable = try("{{${each.value.multicast.pim_source_specific_multicast_access_list_variable}}}", null)
  pim_spt_threshold                                  = try(each.value.multicast.pim_spt_threshold, null)
  pim_spt_threshold_variable                         = try("{{${each.value.multicast.pim_spt_threshold_variable}}}", null)
  spt_only                                           = try(each.value.multicast.spt_only, null)
  spt_only_variable                                  = try(each.value.multicast.spt_only_variable, null)
  static_rp_addresses = try(length(each.value.multicast.static_rp_addresses) == 0, true) ? null : [for static_rp in each.value.multicast.static_rp_addresses : {
    ip_address           = try(static_rp.ip_address, null)
    ip_address_variable  = try("{{${static_rp.ip_address_variable}}}", null)
    access_list          = try(static_rp.access_list, null)
    access_list_variable = try("{{${static_rp.access_list_variable}}}", null)
    override             = try(static_rp.override, null)
    override_variable    = try("{{${static_rp.override_variable}}}", null)
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

resource "sdwan_service_routing_ospf_feature" "service_routing_ospf_feature" {
  for_each = {
    for ospf_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for ospf in try(profile.ospf_features, []) : {
          profile = profile
          ospf    = ospf
        }
      ]
    ])
    : "${ospf_item.profile.name}-${ospf_item.ospf.name}" => ospf_item
  }
  name                                               = each.value.ospf.name
  description                                        = try(each.value.ospf.description, null)
  feature_profile_id                                 = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  router_id                                          = try(each.value.ospf.router_id, null)
  router_id_variable                                 = try("{{${each.value.ospf.router_id_variable}}}", null)
  reference_bandwidth                                = try(each.value.ospf.reference_bandwidth, null)
  reference_bandwidth_variable                       = try("{{${each.value.ospf.reference_bandwidth_variable}}}", null)
  rfc_1583_compatible                                = try(each.value.ospf.rfc1583_compatibility, null)
  rfc_1583_compatible_variable                       = try("{{${each.value.ospf.rfc1583_compatibility_variable}}}", null)
  default_information_originate                      = try(each.value.ospf.default_originate, null)
  default_information_originate_always               = try(each.value.ospf.default_originate_always, null)
  default_information_originate_always_variable      = try("{{${each.value.ospf.default_originate_always_variable}}}", null)
  default_information_originate_metric               = try(each.value.ospf.default_originate_metric, null)
  default_information_originate_metric_variable      = try("{{${each.value.ospf.default_originate_metric_variable}}}", null)
  default_information_originate_metric_type          = try(each.value.ospf.default_originate_metric_type, null)
  default_information_originate_metric_type_variable = try("{{${each.value.ospf.default_originate_metric_type_variable}}}", null)
  distance_external                                  = try(each.value.ospf.distance_external, null)
  distance_external_variable                         = try("{{${each.value.ospf.distance_external_variable}}}", null)
  distance_inter_area                                = try(each.value.ospf.distance_inter_area, null)
  distance_inter_area_variable                       = try("{{${each.value.ospf.distance_inter_area_variable}}}", null)
  distance_intra_area                                = try(each.value.ospf.distance_intra_area, null)
  distance_intra_area_variable                       = try("{{${each.value.ospf.distance_intra_area_variable}}}", null)
  spf_calculation_delay                              = try(each.value.ospf.spf_calculation_delay, null)
  spf_calculation_delay_variable                     = try("{{${each.value.ospf.spf_calculation_delay_variable}}}", null)
  spf_initial_hold_time                              = try(each.value.ospf.spf_initial_hold_time, null)
  spf_initial_hold_time_variable                     = try("{{${each.value.ospf.spf_initial_hold_time_variable}}}", null)
  spf_maximum_hold_time                              = try(each.value.ospf.spf_maximum_hold_time, null)
  spf_maximum_hold_time_variable                     = try("{{${each.value.ospf.spf_maximum_hold_time_variable}}}", null)
  route_policy_id                                    = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${each.value.ospf.route_policy}"].id, null)
  redistributes = try(length(each.value.ospf.redistributes) == 0, true) ? null : [for redistribute in each.value.ospf.redistributes : {
    protocol                      = try(redistribute.protocol, null)
    protocol_variable             = try("{{${redistribute.protocol_variable}}}", null)
    nat_dia                       = try(redistribute.dia, null)
    nat_dia_variable              = try("{{${redistribute.dia_variable}}}", null)
    route_policy_id               = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  router_lsas = try(length(each.value.ospf.router_lsa_advertisement_type) == 0, true) ? null : [{
    type          = try(each.value.ospf.router_lsa_advertisement_type, null)
    type_variable = try("{{${each.value.ospf.router_lsa_advertisement_type_variable}}}", null)
    time          = try(each.value.ospf.router_lsa_advertisement_time, null)
    time_variable = try("{{${each.value.ospf.router_lsa_advertisement_time_variable}}}", null)
  }]
  areas = try(length(each.value.ospf.areas) == 0, true) ? null : [for area in each.value.ospf.areas : {
    area_number          = try(area.number, null)
    area_number_variable = try("{{${area.number_variable}}}", null)
    area_type            = try(area.type, null)
    area_type_variable   = try("{{${area.type_variable}}}", null)
    no_summary           = try(area.no_summary, null)
    no_summary_variable  = try("{{${area.no_summary_variable}}}", null)
    interfaces = try(length(area.interfaces) == 0, true) ? null : [for interface in area.interfaces : {
      name                                = try(interface.name, null)
      name_variable                       = try("{{${interface.name_variable}}}", null)
      hello_interval                      = try(interface.hello_interval, null)
      hello_interval_variable             = try("{{${interface.hello_interval_variable}}}", null)
      dead_interval                       = try(interface.dead_interval, null)
      dead_interval_variable              = try("{{${interface.dead_interval_variable}}}", null)
      lsa_retransmit_interval             = try(interface.lsa_retransmit_interval, null)
      lsa_retransmit_interval_variable    = try("{{${interface.lsa_retransmit_interval_variable}}}", null)
      cost                                = try(interface.cost, null)
      cost_variable                       = try("{{${interface.cost_variable}}}", null)
      designated_router_priority          = try(interface.designated_router_priority, null)
      designated_router_priority_variable = try("{{${interface.designated_router_priority_variable}}}", null)
      network_type                        = try(interface.network_type, null)
      network_type_variable               = try("{{${interface.network_type_variable}}}", null)
      passive_interface                   = try(interface.passive, null)
      passive_interface_variable          = try("{{${interface.passive_variable}}}", null)
      authentication_type                 = try(interface.authentication_type, null)
      authentication_type_variable        = try("{{${interface.authentication_type_variable}}}", null)
      message_digest_key_id               = try(interface.authentication_message_digest_key_id, null)
      message_digest_key_id_variable      = try("{{${interface.authentication_message_digest_key_id_variable}}}", null)
      message_digest_key                  = try(interface.authentication_message_digest_key, null)
      message_digest_key_variable         = try("{{${interface.authentication_message_digest_key_variable}}}", null)
    }]
    ranges = try(length(area.ranges) == 0, true) ? null : [for range in area.ranges : {
      ip_address            = try(range.network_address, null)
      ip_address_variable   = try("{{${range.network_address_variable}}}", null)
      subnet_mask           = try(range.subnet_mask, null)
      subnet_mask_variable  = try("{{${range.subnet_mask_variable}}}", null)
      cost                  = try(range.cost, null)
      cost_variable         = try("{{${range.cost_variable}}}", null)
      no_advertise          = try(range.no_advertise, null)
      no_advertise_variable = try("{{${range.no_advertise_variable}}}", null)
    }]
  }]
}

resource "sdwan_service_routing_ospfv3_ipv6_feature" "service_routing_ospfv3_ipv6_feature" {
  for_each = {
    for ospf_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for ospf in try(profile.ospfv3_ipv6_features, []) : {
          profile = profile
          ospf    = ospf
        }
      ]
    ])
    : "${ospf_item.profile.name}-${ospf_item.ospf.name}" => ospf_item
  }
  name                                               = each.value.ospf.name
  description                                        = try(each.value.ospf.description, null)
  feature_profile_id                                 = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  router_id                                          = try(each.value.ospf.router_id, null)
  router_id_variable                                 = try("{{${each.value.ospf.router_id_variable}}}", null)
  reference_bandwidth                                = try(each.value.ospf.reference_bandwidth, null)
  reference_bandwidth_variable                       = try("{{${each.value.ospf.reference_bandwidth_variable}}}", null)
  rfc_1583_compatible                                = try(each.value.ospf.rfc1583_compatibility, null)
  rfc_1583_compatible_variable                       = try("{{${each.value.ospf.rfc1583_compatibility_variable}}}", null)
  default_information_originate                      = try(each.value.ospf.default_originate, null)
  default_information_originate_always               = try(each.value.ospf.default_originate_always, null)
  default_information_originate_always_variable      = try("{{${each.value.ospf.default_originate_always_variable}}}", null)
  default_information_originate_metric               = try(each.value.ospf.default_originate_metric, null)
  default_information_originate_metric_variable      = try("{{${each.value.ospf.default_originate_metric_variable}}}", null)
  default_information_originate_metric_type          = try(each.value.ospf.default_originate_metric_type, null)
  default_information_originate_metric_type_variable = try("{{${each.value.ospf.default_originate_metric_type_variable}}}", null)
  distance                                           = try(each.value.ospf.distance, null)
  distance_external                                  = try(each.value.ospf.distance_external, null)
  distance_external_variable                         = try("{{${each.value.ospf.distance_external_variable}}}", null)
  distance_inter_area                                = try(each.value.ospf.distance_inter_area, null)
  distance_inter_area_variable                       = try("{{${each.value.ospf.distance_inter_area_variable}}}", null)
  distance_intra_area                                = try(each.value.ospf.distance_intra_area, null)
  distance_intra_area_variable                       = try("{{${each.value.ospf.distance_intra_area_variable}}}", null)
  filter                                             = try(each.value.ospf.filter, null)
  filter_variable                                    = try("{{${each.value.ospf.filter_variable}}}", null)
  spf_calculation_delay                              = try(each.value.ospf.spf_calculation_delay, null)
  spf_calculation_delay_variable                     = try("{{${each.value.ospf.spf_calculation_delay_variable}}}", null)
  spf_initial_hold_time                              = try(each.value.ospf.spf_initial_hold_time, null)
  spf_initial_hold_time_variable                     = try("{{${each.value.ospf.spf_initial_hold_time_variable}}}", null)
  spf_maximum_hold_time                              = try(each.value.ospf.spf_maximum_hold_time, null)
  spf_maximum_hold_time_variable                     = try("{{${each.value.ospf.spf_maximum_hold_time_variable}}}", null)
  route_policy_id                                    = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${each.value.ospf.route_policy}"].id, null)
  redistributes = try(length(each.value.ospf.redistributes) == 0, true) ? null : [for redistribute in each.value.ospf.redistributes : {
    protocol                      = try(redistribute.protocol, null)
    protocol_variable             = try("{{${redistribute.protocol_variable}}}", null)
    route_policy_id               = try(sdwan_service_route_policy_feature.service_route_policy_feature["${each.value.profile.name}-${redistribute.route_policy}"].id, null)
    translate_rib_metric          = try(redistribute.translate_rib_metric, null)
    translate_rib_metric_variable = try("{{${redistribute.translate_rib_metric_variable}}}", null)
  }]
  router_lsa_action                   = try(each.value.ospf.router_lsa_action, null)
  router_lsa_on_startup_time          = try(each.value.ospf.router_lsa_on_startup_time, null)
  router_lsa_on_startup_time_variable = try("{{${each.value.ospf.router_lsa_on_startup_time_variable}}}", null)
  areas = try(length(each.value.ospf.areas) == 0, true) ? null : [for area in each.value.ospf.areas : {
    area_number               = try(area.number, null)
    area_number_variable      = try("{{${area.number_variable}}}", null)
    area_type                 = try(area.type, null)
    area_type_variable        = try("{{${area.type_variable}}}", null)
    always_translate          = try(area.always_translate, null)
    always_translate_variable = try("{{${area.always_translate_variable}}}", null)
    no_summary                = try(area.no_summary, null)
    no_summary_variable       = try("{{${area.no_summary_variable}}}", null)
    interfaces = try(length(area.interfaces) == 0, true) ? null : [for interface in area.interfaces : {
      name                             = try(interface.name, null)
      name_variable                    = try("{{${interface.name_variable}}}", null)
      authentication_type              = try(interface.authentication_type, null)
      authentication_type_variable     = try("{{${interface.authentication_type_variable}}}", null)
      authentication_spi               = try(interface.authentication_ipsec_spi, null)
      authentication_spi_variable      = try("{{${interface.authentication_ipsec_spi_variable}}}", null)
      authentication_key               = try(interface.authentication_ipsec_key, null)
      authentication_key_variable      = try("{{${interface.authentication_ipsec_key_variable}}}", null)
      cost                             = try(interface.cost, null)
      cost_variable                    = try("{{${interface.cost_variable}}}", null)
      hello_interval                   = try(interface.hello_interval, null)
      hello_interval_variable          = try("{{${interface.hello_interval_variable}}}", null)
      dead_interval                    = try(interface.dead_interval, null)
      dead_interval_variable           = try("{{${interface.dead_interval_variable}}}", null)
      lsa_retransmit_interval          = try(interface.lsa_retransmit_interval, null)
      lsa_retransmit_interval_variable = try("{{${interface.lsa_retransmit_interval_variable}}}", null)
      network_type                     = try(interface.network_type, null)
      network_type_variable            = try("{{${interface.network_type_variable}}}", null)
      passive_interface                = try(interface.passive, null)
      passive_interface_variable       = try("{{${interface.passive_variable}}}", null)
    }]
    ranges = try(length(area.ranges) == 0, true) ? null : [for range in area.ranges : {
      cost                  = try(range.cost, null)
      cost_variable         = try("{{${range.cost_variable}}}", null)
      prefix                = try(range.prefix, null)
      prefix_variable       = try("{{${range.prefix_variable}}}", null)
      no_advertise          = try(range.no_advertise, null)
      no_advertise_variable = try("{{${range.no_advertise_variable}}}", null)
    }]
  }]
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
    protocol = upper(try(s.protocol, local.defaults.sdwan.feature_profiles.service_profiles.route_policies.sequences.protocol))
  }]
}

resource "sdwan_service_switchport_feature" "service_switchport_feature" {
  for_each = {
    for switchport_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for switchport in try(profile.switchport_features, []) : {
          profile    = profile
          switchport = switchport
        }
      ]
    ])
    : "${switchport_item.profile.name}-${switchport_item.switchport.name}" => switchport_item
  }
  name                  = each.value.switchport.name
  description           = try(each.value.switchport.description, null)
  feature_profile_id    = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  age_out_time          = try(each.value.switchport.age_out_time, null)
  age_out_time_variable = try("{{${each.value.switchport.age_out_time_variable}}}", null)
  interfaces = try(length(each.value.switchport.interfaces) == 0, true) ? null : [for interface in each.value.switchport.interfaces : {
    switchport_access_vlan                  = try(interface.access_vlan, null)
    switchport_access_vlan_variable         = try("{{${interface.access_vlan_variable}}}", null)
    control_direction                       = try(interface.control_direction, null)
    control_direction_variable              = try("{{${interface.control_direction_variable}}}", null)
    critical_vlan                           = try(interface.critical_vlan, null)
    critical_vlan_variable                  = try("{{${interface.critical_vlan_variable}}}", null)
    duplex                                  = try(interface.duplex, null)
    duplex_variable                         = try("{{${interface.duplex_variable}}}", null)
    enable_periodic_reauth                  = try(interface.enable_periodic_reauth, null)
    enable_periodic_reauth_variable         = try("{{${interface.enable_periodic_reauth_variable}}}", null)
    enable_voice                            = try(interface.enable_voice, null)
    enable_voice_variable                   = try("{{${interface.enable_voice_variable}}}", null)
    guest_vlan                              = try(interface.guest_vlan, null)
    guest_vlan_variable                     = try("{{${interface.guest_vlan_variable}}}", null)
    host_mode                               = try(interface.host_mode, null)
    host_mode_variable                      = try("{{${interface.host_mode_variable}}}", null)
    inactivity                              = try(interface.inactivity, null)
    inactivity_variable                     = try("{{${interface.inactivity_variable}}}", null)
    interface_name                          = try(interface.name, null)
    interface_name_variable                 = try("{{${interface.name_variable}}}", null)
    mac_authentication_bypass               = try(interface.mac_authentication_bypass, null)
    mac_authentication_bypass_variable      = try("{{${interface.mac_authentication_bypass_variable}}}", null)
    mode                                    = try(interface.mode, null)
    pae_enable                              = try(interface.pae_enable, null)
    pae_enable_variable                     = try("{{${interface.pae_enable_variable}}}", null)
    port_control                            = try(interface.port_control, null)
    port_control_variable                   = try("{{${interface.port_control_variable}}}", null)
    reauthentication                        = try(interface.reauthentication, null)
    reauthentication_variable               = try("{{${interface.reauthentication_variable}}}", null)
    restricted_vlan                         = try(interface.restricted_vlan, null)
    restricted_vlan_variable                = try("{{${interface.restricted_vlan_variable}}}", null)
    shutdown                                = try(interface.shutdown, null)
    shutdown_variable                       = try("{{${interface.shutdown_variable}}}", null)
    speed                                   = try(interface.speed, null)
    speed_variable                          = try("{{${interface.speed_variable}}}", null)
    switchport_trunk_allowed_vlans          = length(concat(try(interface.trunk_allowed_vlans, []), try(interface.trunk_allowed_vlans_ranges, []))) > 0 ? join(",", concat([for p in try(interface.trunk_allowed_vlans, []) : p], [for r in try(interface.trunk_allowed_vlans_ranges, []) : "${r.from}-${r.to}"])) : null
    switchport_trunk_allowed_vlans_variable = try("{{${interface.trunk_allowed_vlans_variable}}}", null)
    switchport_trunk_native_vlan            = try(interface.trunk_native_vlan, null)
    switchport_trunk_native_vlan_variable   = try("{{${interface.trunk_native_vlan_variable}}}", null)
    voice_vlan                              = try(interface.voice_vlan, null)
    voice_vlan_variable                     = try("{{${interface.voice_vlan_variable}}}", null)
  }]
  static_mac_addresses = try(length(each.value.switchport.static_mac_addresses) == 0, true) ? null : [for mac in each.value.switchport.static_mac_addresses : {
    interface_name          = try(mac.interface_name, null)
    interface_name_variable = try("{{${mac.interface_name_variable}}}", null)
    mac_address             = try(mac.mac_address, null)
    mac_address_variable    = try("{{${mac.mac_address_variable}}}", null)
    vlan_id                 = try(mac.vlan_id, null)
    vlan_id_variable        = try("{{${mac.vlan_id_variable}}}", null)
  }]
}

resource "sdwan_service_ipv6_acl_feature" "service_ipv6_acl_feature" {
  for_each = {
    for acl_item in flatten([
      for profile in try(local.feature_profiles.service_profiles, []) : [
        for acl in try(profile.ipv6_acls, []) : {
          profile = profile
          acl     = acl
        }
      ]
    ])
    : "${acl_item.profile.name}-${acl_item.acl.name}" => acl_item
  }
  name               = each.value.acl.name
  description        = try(each.value.acl.description, null)
  feature_profile_id = sdwan_service_feature_profile.service_feature_profile[each.value.profile.name].id
  default_action     = try(each.value.acl.default_action, "drop")
  sequences = try(length(each.value.acl.sequences) == 0, true) ? null : [for s in each.value.acl.sequences : {
    actions = length(keys(try(s.actions, {}))) > 0 ? [{
      accept_counter_name   = s.base_action == "accept" ? try(s.actions.counter_name, null) : null
      accept_log            = s.base_action == "accept" ? try(s.actions.log, null) : null
      accept_mirror_list_id = s.base_action == "accept" && can(s.actions.mirror) ? sdwan_policy_object_mirror.policy_object_mirror[s.actions.mirror].id : null
      accept_policer_id     = s.base_action == "accept" && can(s.actions.policer) ? sdwan_policy_object_policer.policy_object_policer[s.actions.policer].id : null
      accept_traffic_class  = s.base_action == "accept" ? try(s.actions.traffic_class, null) : null
      accept_set_next_hop   = s.base_action == "accept" ? try(s.actions.ipv6_next_hop, null) : null
      drop_counter_name     = s.base_action == "drop" ? try(s.actions.counter_name, null) : null
      drop_log              = s.base_action == "drop" ? try(s.actions.log, null) : null
    }] : null
    base_action = length(keys(try(s.actions, {}))) > 0 ? null : s.base_action
    match_entries = length(keys(try(s.match_entries, {}))) > 0 ? [{
      destination_data_prefix         = try(s.match_entries.destination_data_prefix, null)
      destination_data_prefix_list_id = can(s.match_entries.destination_data_prefix_list) ? sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[s.match_entries.destination_data_prefix_list].id : null
      destination_ports = try(length(s.match_entries.destination_ports) == 0, true) ? null : [for p in s.match_entries.destination_ports : {
        port = p
      }]
      traffic_class              = try(s.match_entries.traffic_classes, null)
      icmp_messages              = try(s.match_entries.icmpv6_messages, null)
      packet_length              = try(s.match_entries.packet_length, null)
      source_data_prefix         = try(s.match_entries.source_data_prefix, null)
      source_data_prefix_list_id = can(s.match_entries.source_data_prefix_list) ? sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[s.match_entries.source_data_prefix_list].id : null
      source_ports = try(length(s.match_entries.source_ports) == 0, true) ? null : [for p in s.match_entries.source_ports : {
        port = p
      }]
      tcp_state   = try(s.match_entries.tcp_state, null)
      next_header = try(s.match_entries.next_header, null)
    }] : null
    sequence_id   = s.id
    sequence_name = try(s.name, local.defaults.sdwan.feature_profiles.service_profiles.ipv6_acls.sequences.name)
    }
  ]
}
