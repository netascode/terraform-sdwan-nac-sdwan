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

resource "sdwan_service_ipv4_acl_feature" "service_ipv4_acl_feature" {
  for_each = {
    for acl_item in flatten([
      for profile in lookup(local.feature_profiles, "service_profiles", []) : [
        for acl in lookup(profile, "ipv4_acls", []) : {
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
      gateway                  = try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv4_static_routes.gateway) == "nexthop" ? "nextHop" : try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv4_static_routes.gateway)
      dhcp                     = try(route.gateway == "dhcp" ? true : null, null)
      null0                    = try(route.gateway == "null0" ? true : null, null)
      vpn                      = try(route.gateway == "vpn" ? true : null, null)
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
      ]
    }
  ]
  ipv6_static_routes = try(length(each.value.lan_vpn.ipv6_static_routes) == 0, true) ? null : [
    for route in each.value.lan_vpn.ipv6_static_routes : {
      prefix          = try(route.prefix, null)
      prefix_variable = try("{{${route.prefix_variable}}}", null)
      gateway         = try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv6_static_routes.gateway) == "nexthop" ? "nextHop" : try(route.gateway, local.defaults.sdwan.feature_profiles.service_profiles.lan_vpns.ipv6_static_routes.gateway)
      nat             = try(route.gateway == "nat" ? upper(route.nat) : null, null)
      nat_variable    = try(route.gateway == "nat" ? "{{${route.nat_variable}}}" : null, null)
      null0           = try(route.gateway == "null0" ? true : null, null)
      next_hops = try(length(route.next_hops) == 0, true) ? null : [
        for nh in route.next_hops : {
          address                          = try(nh.address, null)
          address_variable                 = try("{{${nh.address_variable}}}", null)
          administrative_distance          = try(nh.administrative_distance, null)
          administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
        }
      ]
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
      vpn                      = 0
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
  vpn          = try(each.value.lan_vpn.vpn_id, null)
  vpn_variable = try("{{${each.value.lan_vpn.vpn_id_variable}}}", null)
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
