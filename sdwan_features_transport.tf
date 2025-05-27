resource "sdwan_transport_cellular_profile_feature" "transport_cellular_profile_feature" {
  for_each = {
    for cellular_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
        for cellular in try(profile.cellular_profiles, []) : {
          profile  = profile
          cellular = cellular
        }
      ]
    ])
    : "${cellular_item.profile.name}-${cellular_item.cellular.name}" => cellular_item
  }
  name                              = each.value.cellular.name
  description                       = try(each.value.cellular.description, null)
  feature_profile_id                = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  access_point_name                 = try(each.value.cellular.access_point_name, null)
  access_point_name_variable        = try("{{${each.value.cellular.access_point_name_variable}}}", null)
  requires_authentication           = try(each.value.cellular.authentication_enable, null)
  authentication_type               = try(each.value.cellular.authentication_type, null)
  authentication_type_variable      = try("{{${each.value.cellular.authentication_type_variable}}}", null)
  profile_id                        = try(each.value.cellular.profile_id, null)
  profile_id_variable               = try("{{${each.value.cellular.profile_id_variable}}}", null)
  profile_username                  = try(each.value.cellular.profile_username, null)
  profile_username_variable         = try("{{${each.value.cellular.profile_username_variable}}}", null)
  profile_password                  = try(each.value.cellular.profile_password, null)
  profile_password_variable         = try("{{${each.value.cellular.profile_password_variable}}}", null)
  packet_data_network_type          = try(each.value.cellular.packet_data_network_type, null)
  packet_data_network_type_variable = try("{{${each.value.cellular.packet_data_network_type_variable}}}", null)
  no_overwrite                      = try(each.value.cellular.no_overwrite, null)
  no_overwrite_variable             = try("{{${each.value.cellular.no_overwrite_variable}}}", null)
}

resource "sdwan_transport_gps_feature" "transport_gps_feature" {
  for_each = {
    for gps_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
        for gps in try(profile.gps_features, []) : {
          profile = profile
          gps     = gps
        }
      ]
    ])
    : "${gps_item.profile.name}-${gps_item.gps.name}" => gps_item
  }
  name                              = each.value.gps.name
  description                       = try(each.value.gps.description, null)
  feature_profile_id                = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  gps_enable                        = try(each.value.gps.gps_enable, local.defaults.sdwan.feature_profiles.transport_profiles.gps.gps_enable)
  gps_enable_variable               = try("{{${each.value.gps.gps_enable_variable}}}", null)
  gps_mode                          = try(each.value.gps.gps_mode, null)
  gps_mode_variable                 = try("{{${each.value.gps.gps_mode_variable}}}", null)
  nmea_enable                       = try(each.value.gps.nmea_enable, null)
  nmea_enable_variable              = try("{{${each.value.gps.nmea_enable_variable}}}", null)
  nmea_source_address               = try(each.value.gps.nmea_source_address, null)
  nmea_source_address_variable      = try("{{${each.value.gps.nmea_source_address_variable}}}", null)
  nmea_destination_address          = try(each.value.gps.nmea_destination_address, null)
  nmea_destination_address_variable = try("{{${each.value.gps.nmea_destination_address_variable}}}", null)
  nmea_destination_port             = try(each.value.gps.nmea_destination_port, null)
  nmea_destination_port_variable    = try("{{${each.value.gps.nmea_destination_port_variable}}}", null)
}

resource "sdwan_transport_tracker_group_feature" "transport_tracker_group_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
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
  feature_profile_id       = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  tracker_boolean          = try(each.value.tracker.tracker_boolean, null)
  tracker_boolean_variable = try("{{${each.value.tracker.tracker_boolean_variable}}}", null)
  tracker_elements = try(length(each.value.tracker.trackers) == 0, true) ? null : [for t in each.value.tracker.trackers : {
    tracker_id = sdwan_transport_tracker_feature.transport_tracker_feature["${each.value.profile.name}-${t}"].id
  }]
}

resource "sdwan_transport_tracker_feature" "transport_tracker_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
        for tracker in try(profile.ipv4_trackers, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                           = each.value.tracker.name
  description                    = try(each.value.tracker.description, null)
  feature_profile_id             = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  endpoint_api_url               = try(each.value.tracker.endpoint_api_url, null)
  endpoint_api_url_variable      = try("{{${each.value.tracker.endpoint_api_url_variable}}}", null)
  endpoint_dns_name              = try(each.value.tracker.endpoint_dns_name, null)
  endpoint_dns_name_variable     = try("{{${each.value.tracker.endpoint_dns_name_variable}}}", null)
  endpoint_ip                    = try(each.value.tracker.endpoint_ip, each.value.tracker.endpoint_tcp_udp_ip, null)
  endpoint_ip_variable           = try("{{${each.value.tracker.endpoint_ip_variable}}}", null)
  endpoint_tracker_type          = try(each.value.tracker.endpoint_tracker_type, null)
  endpoint_tracker_type_variable = try("{{${each.value.tracker.endpoint_tracker_type_variable}}}", null)
  interval                       = try(each.value.tracker.interval, null)
  interval_variable              = try("{{${each.value.tracker.interval_variable}}}", null)
  multiplier                     = try(each.value.tracker.multiplier, null)
  multiplier_variable            = try("{{${each.value.tracker.multiplier_variable}}}", null)
  threshold                      = try(each.value.tracker.threshold, null)
  threshold_variable             = try("{{${each.value.tracker.threshold_variable}}}", null)
  tracker_name                   = try(each.value.tracker.tracker_name, null)
  tracker_name_variable          = try("{{${each.value.tracker.tracker_name_variable}}}", null)
  tracker_type                   = try(each.value.tracker.tracker_type, null)
  tracker_type_variable          = try("{{${each.value.tracker.tracker_type_variable}}}", null)
}

resource "sdwan_transport_ipv6_tracker_group_feature" "transport_ipv6_tracker_group_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
        for tracker in try(profile.ipv6_tracker_groups, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                     = each.value.tracker.name
  description              = try(each.value.tracker.description, null)
  feature_profile_id       = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  tracker_boolean          = try(each.value.tracker.tracker_boolean, null)
  tracker_boolean_variable = try("{{${each.value.tracker.tracker_boolean_variable}}}", null)
  tracker_elements = try(length(each.value.tracker.trackers) == 0, true) ? null : [for t in each.value.tracker.trackers : {
    tracker_id = sdwan_transport_ipv6_tracker_feature.transport_ipv6_tracker_feature["${each.value.profile.name}-${t}"].id
  }]
  tracker_name          = try(each.value.tracker.tracker_name, null)
  tracker_name_variable = try("{{${each.value.tracker.tracker_name_variable}}}", null)
}

resource "sdwan_transport_ipv6_tracker_feature" "transport_ipv6_tracker_feature" {
  for_each = {
    for tracker_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, []) : [
        for tracker in try(profile.ipv6_trackers, []) : {
          profile = profile
          tracker = tracker
        }
      ]
    ])
    : "${tracker_item.profile.name}-${tracker_item.tracker.name}" => tracker_item
  }
  name                           = each.value.tracker.name
  description                    = try(each.value.tracker.description, null)
  feature_profile_id             = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  endpoint_api_url               = try(each.value.tracker.endpoint_api_url, null)
  endpoint_api_url_variable      = try("{{${each.value.tracker.endpoint_api_url_variable}}}", null)
  endpoint_dns_name              = try(each.value.tracker.endpoint_dns_name, null)
  endpoint_dns_name_variable     = try("{{${each.value.tracker.endpoint_dns_name_variable}}}", null)
  endpoint_ip                    = try(each.value.tracker.endpoint_ip, each.value.tracker.endpoint_tcp_udp_ip, null)
  endpoint_ip_variable           = try("{{${each.value.tracker.endpoint_ip_variable}}}", null)
  endpoint_tracker_type          = try(each.value.tracker.endpoint_tracker_type, null)
  endpoint_tracker_type_variable = try("{{${each.value.tracker.endpoint_tracker_type_variable}}}", null)
  interval                       = try(each.value.tracker.interval, null)
  interval_variable              = try("{{${each.value.tracker.interval_variable}}}", null)
  multiplier                     = try(each.value.tracker.multiplier, null)
  multiplier_variable            = try("{{${each.value.tracker.multiplier_variable}}}", null)
  threshold                      = try(each.value.tracker.threshold, null)
  threshold_variable             = try("{{${each.value.tracker.threshold_variable}}}", null)
  tracker_name                   = try(each.value.tracker.tracker_name, null)
  tracker_name_variable          = try("{{${each.value.tracker.tracker_name_variable}}}", null)
  tracker_type                   = try(each.value.tracker.tracker_type, null)
  tracker_type_variable          = try("{{${each.value.tracker.tracker_type_variable}}}", null)
}

resource "sdwan_transport_management_vpn_feature" "transport_management_vpn_feature" {
  for_each = {
    for transport in try(local.feature_profiles.transport_profiles, {}) :
    "${transport.name}-management_vpn" => transport
    if try(transport.management_vpn, null) != null
  }
  name               = try(each.value.management_vpn.name, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.name)
  description        = try(each.value.management_vpn.description, null)
  feature_profile_id = sdwan_transport_feature_profile.transport_feature_profile[each.value.name].id
  ipv4_static_routes = try(length(each.value.management_vpn.ipv4_static_routes) == 0, true) ? null : [for route in each.value.management_vpn.ipv4_static_routes : {
    administrative_distance          = try(route.administrative_distance, null)
    administrative_distance_variable = try("{{${route.administrative_distance_variable}}}", null)
    gateway                          = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ipv4_static_routes.gateway)
    network_address                  = try(route.network_address, null)
    network_address_variable         = try("{{${route.network_address_variable}}}", null)
    next_hops = try(length(route.next_hops) == 0, true) ? null : [for nh in route.next_hops : {
      address                          = try(nh.address, null)
      address_variable                 = try("{{${nh.address_variable}}}", null)
      administrative_distance          = try(nh.administrative_distance, null)
      administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
    }]
    subnet_mask          = try(route.subnet_mask, null)
    subnet_mask_variable = try("{{${route.subnet_mask_variable}}}", null)
  }]
  ipv6_static_routes = try(length(each.value.management_vpn.ipv6_static_routes) == 0, true) ? null : [for route in each.value.management_vpn.ipv6_static_routes : {
    nat          = try(route.nat, null)
    nat_variable = try("{{${route.nat_variable}}}", null)
    next_hops = try(length(route.next_hops) == 0, true) ? null : [for nh in route.next_hops : {
      address                          = try(nh.address, null)
      address_variable                 = try("{{${nh.address_variable}}}", null)
      administrative_distance          = try(nh.administrative_distance, null)
      administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
    }]
    gateway         = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ipv6_static_routes.gateway)
    null0           = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ipv6_static_routes.gateway) == "null0" ? true : null
    prefix          = try(route.prefix, null)
    prefix_variable = try("{{${route.prefix_variable}}}", null)
  }]
  new_host_mappings = try(length(each.value.management_vpn.host_mappings) == 0, true) ? null : [for host in each.value.management_vpn.host_mappings : {
    host_name                     = try(host.hostname, null)
    host_name_variable            = try("{{${host.hostname_variable}}}", null)
    list_of_ip_addresses          = try(host.ips, null)
    list_of_ip_addresses_variable = try("{{${host.ips_variable}}}", null)
  }]
  primary_dns_address_ipv4            = try(each.value.management_vpn.ipv4_primary_dns_address, null)
  primary_dns_address_ipv4_variable   = try("{{${each.value.management_vpn.ipv4_primary_dns_address_variable}}}", null)
  primary_dns_address_ipv6            = try(each.value.management_vpn.ipv6_primary_dns_address, null)
  primary_dns_address_ipv6_variable   = try("{{${each.value.management_vpn.ipv6_primary_dns_address_variable}}}", null)
  secondary_dns_address_ipv4          = try(each.value.management_vpn.ipv4_secondary_dns_address, null)
  secondary_dns_address_ipv4_variable = try("{{${each.value.management_vpn.ipv4_secondary_dns_address_variable}}}", null)
  secondary_dns_address_ipv6          = try(each.value.management_vpn.ipv6_secondary_dns_address, null)
  secondary_dns_address_ipv6_variable = try("{{${each.value.management_vpn.ipv6_secondary_dns_address_variable}}}", null)
  vpn_description                     = try(each.value.management_vpn.vpn_description, null)
  vpn_description_variable            = try("{{${each.value.management_vpn.vpn_description_variable}}}", null)
}

resource "sdwan_transport_management_vpn_interface_ethernet_feature" "transport_management_vpn_interface_ethernet_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for management_vpn in try([profile.management_vpn], []) : [
          for interface in try(management_vpn.ethernet_interfaces, []) : {
            profile        = profile
            management_vpn = management_vpn
            interface      = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-management_vpn-${interface_item.interface.name}" => interface_item
  }
  name                                = each.value.interface.name
  description                         = try(each.value.interface.description, null)
  feature_profile_id                  = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_management_vpn_feature_id = sdwan_transport_management_vpn_feature.transport_management_vpn_feature["${each.value.profile.name}-management_vpn"].id
  arp_entries = try(length(each.value.interface.arp_entries) == 0, true) ? null : [for arp in each.value.interface.arp_entries : {
    ip_address           = try(arp.ip_address, null)
    ip_address_variable  = try("{{${arp.ip_address_variable}}}", null)
    mac_address          = try(arp.mac_address, null)
    mac_address_variable = try("{{${arp.mac_address_variable}}}", null)
  }]
  arp_timeout                         = try(each.value.interface.arp_timeout, null)
  arp_timeout_variable                = try("{{${each.value.interface.arp_timeout_variable}}}", null)
  autonegotiate                       = try(each.value.interface.autonegotiate, null)
  autonegotiate_variable              = try("{{${each.value.interface.autonegotiate_variable}}}", null)
  duplex                              = try(each.value.interface.duplex, null)
  duplex_variable                     = try("{{${each.value.interface.duplex_variable}}}", null)
  enable_dhcpv6                       = try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ethernet_interfaces.ipv6_configuration_type) == "dynamic" ? true : null
  icmp_redirect_disable               = try(each.value.interface.icmp_redirect_disable, null)
  icmp_redirect_disable_variable      = try("{{${each.value.interface.icmp_redirect_disable_variable}}}", null)
  interface_description               = try(each.value.interface.interface_description, null)
  interface_description_variable      = try("{{${each.value.interface.interface_description_variable}}}", null)
  interface_mtu                       = try(each.value.interface.interface_mtu, null)
  interface_mtu_variable              = try("{{${each.value.interface.interface_mtu_variable}}}", null)
  interface_name                      = try(each.value.interface.interface_name, null)
  interface_name_variable             = try("{{${each.value.interface.interface_name_variable}}}", null)
  ip_directed_broadcast               = try(each.value.interface.ip_directed_broadcast, null)
  ip_directed_broadcast_variable      = try("{{${each.value.interface.ip_directed_broadcast_variable}}}", null)
  ip_mtu                              = try(each.value.interface.ip_mtu, null)
  ip_mtu_variable                     = try("{{${each.value.interface.ip_mtu_variable}}}", null)
  ipv4_auto_detect_bandwidth          = try(each.value.interface.auto_detect_bandwidth, null)
  ipv4_auto_detect_bandwidth_variable = try("{{${each.value.interface.auto_detect_bandwidth_variable}}}", null)
  ipv4_address                        = try(each.value.interface.ipv4_address, null)
  ipv4_address_variable               = try("{{${each.value.interface.ipv4_address_variable}}}", null)
  ipv4_configuration_type             = try(each.value.interface.ipv4_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ethernet_interfaces.ipv4_configuration_type)
  ipv4_dhcp_distance                  = try(each.value.interface.ipv4_dhcp_distance, null)
  ipv4_dhcp_distance_variable         = try("{{${each.value.interface.ipv4_dhcp_distance_variable}}}", null)
  ipv4_dhcp_helper                    = try(each.value.interface.ipv4_dhcp_helpers, null)
  ipv4_dhcp_helper_variable           = try("{{${each.value.interface.ipv4_dhcp_helpers_variable}}}", null)
  ipv4_iperf_server                   = try(each.value.interface.iperf_server, null)
  ipv4_iperf_server_variable          = try("{{${each.value.interface.iperf_server_variable}}}", null)
  ipv4_secondary_addresses = try(length(each.value.interface.ipv4_secondary_addresses) == 0, true) ? null : [for a in each.value.interface.ipv4_secondary_addresses : {
    address              = try(a.address, null)
    address_variable     = try("{{${a.address_variable}}}", null)
    subnet_mask          = try(a.subnet_mask, null)
    subnet_mask_variable = try("{{${a.subnet_mask_variable}}}", null)
  }]
  ipv4_subnet_mask          = try(each.value.interface.ipv4_subnet_mask, null)
  ipv4_subnet_mask_variable = try("{{${each.value.interface.ipv4_subnet_mask_variable}}}", null)
  ipv6_address              = try(each.value.interface.ipv6_address, null)
  ipv6_address_variable     = try("{{${each.value.interface.ipv6_address_variable}}}", null)
  ipv6_configuration_type   = try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.management_vpn.ethernet_interfaces.ipv6_configuration_type)
  load_interval             = try(each.value.interface.load_interval, null)
  load_interval_variable    = try("{{${each.value.interface.load_interval_variable}}}", null)
  mac_address               = try(each.value.interface.mac_address, null)
  mac_address_variable      = try("{{${each.value.interface.mac_address_variable}}}", null)
  media_type                = try(each.value.interface.media_type, null)
  media_type_variable       = try("{{${each.value.interface.media_type_variable}}}", null)
  shutdown                  = try(each.value.interface.shutdown, null)
  shutdown_variable         = try("{{${each.value.interface.shutdown_variable}}}", null)
  speed                     = try(each.value.interface.speed, null)
  speed_variable            = try("{{${each.value.interface.speed_variable}}}", null)
  tcp_mss                   = try(each.value.interface.tcp_mss, null)
  tcp_mss_variable          = try("{{${each.value.interface.tcp_mss_variable}}}", null)
}

resource "sdwan_transport_wan_vpn_feature" "transport_wan_vpn_feature" {
  for_each = {
    for transport in try(local.feature_profiles.transport_profiles, {}) :
    "${transport.name}-wan_vpn" => transport
    if try(transport.wan_vpn, null) != null
  }
  name                         = try(each.value.wan_vpn.name, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.name)
  description                  = try(each.value.wan_vpn.description, null)
  feature_profile_id           = sdwan_transport_feature_profile.transport_feature_profile[each.value.name].id
  enhance_ecmp_keying          = try(each.value.wan_vpn.enhance_ecmp_keying, null)
  enhance_ecmp_keying_variable = try("{{${each.value.wan_vpn.enhance_ecmp_keying_variable}}}", null)
  ipv4_static_routes = try(length(each.value.wan_vpn.ipv4_static_routes) == 0, true) ? null : [for route in each.value.wan_vpn.ipv4_static_routes : {
    administrative_distance          = try(route.administrative_distance, null)
    administrative_distance_variable = try("{{${route.administrative_distance_variable}}}", null)
    gateway                          = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ipv4_static_routes.gateway)
    next_hops = try(length(route.next_hops) == 0, true) ? null : [for nh in route.next_hops : {
      address                          = try(nh.address, null)
      address_variable                 = try("{{${nh.address_variable}}}", null)
      administrative_distance          = try(nh.administrative_distance, null)
      administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
    }]
    network_address          = try(route.network_address, null)
    network_address_variable = try("{{${route.network_address_variable}}}", null)
    subnet_mask              = try(route.subnet_mask, null)
    subnet_mask_variable     = try("{{${route.subnet_mask_variable}}}", null)
  }]
  ipv6_static_routes = try(length(each.value.wan_vpn.ipv6_static_routes) == 0, true) ? null : [for route in each.value.wan_vpn.ipv6_static_routes : {
    nat = try(route.nat, null)
    next_hops = try(length(route.next_hops) == 0, true) ? null : [for nh in route.next_hops : {
      address                          = try(nh.address, null)
      address_variable                 = try("{{${nh.address_variable}}}", null)
      administrative_distance          = try(nh.administrative_distance, null)
      administrative_distance_variable = try("{{${nh.administrative_distance_variable}}}", null)
    }]
    gateway         = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ipv6_static_routes.gateway)
    null0           = try(route.gateway, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ipv6_static_routes.gateway) == "null0" ? true : null
    prefix          = try(route.prefix, null)
    prefix_variable = try("{{${route.prefix_variable}}}", null)
  }]
  nat_64_v4_pools = try(length(each.value.wan_vpn.nat_64_v4_pools) == 0, true) ? null : [for pool in each.value.wan_vpn.nat_64_v4_pools : {
    nat64_v4_pool_name                 = try(pool.name, null)
    nat64_v4_pool_name_variable        = try("{{${pool.name_variable}}}", null)
    nat64_v4_pool_overload             = try(pool.overload, null)
    nat64_v4_pool_overload_variable    = try("{{${pool.overload_variable}}}", null)
    nat64_v4_pool_range_end            = try(pool.range_end, null)
    nat64_v4_pool_range_end_variable   = try("{{${pool.range_end_variable}}}", null)
    nat64_v4_pool_range_start          = try(pool.range_start, null)
    nat64_v4_pool_range_start_variable = try("{{${pool.range_start_variable}}}", null)
  }]
  new_host_mappings = try(length(each.value.wan_vpn.host_mappings) == 0, true) ? null : [for host in each.value.wan_vpn.host_mappings : {
    host_name                     = try(host.hostname, null)
    host_name_variable            = try("{{${host.hostname_variable}}}", null)
    list_of_ip_addresses          = try(host.ips, null)
    list_of_ip_addresses_variable = try("{{${host.ips_variable}}}", null)
  }]
  primary_dns_address_ipv4            = try(each.value.wan_vpn.ipv4_primary_dns_address, null)
  primary_dns_address_ipv4_variable   = try("{{${each.value.wan_vpn.ipv4_primary_dns_address_variable}}}", null)
  primary_dns_address_ipv6            = try(each.value.wan_vpn.ipv6_primary_dns_address, null)
  primary_dns_address_ipv6_variable   = try("{{${each.value.wan_vpn.ipv6_primary_dns_address_variable}}}", null)
  secondary_dns_address_ipv4          = try(each.value.wan_vpn.ipv4_secondary_dns_address, null)
  secondary_dns_address_ipv4_variable = try("{{${each.value.wan_vpn.ipv4_secondary_dns_address_variable}}}", null)
  secondary_dns_address_ipv6          = try(each.value.wan_vpn.ipv6_secondary_dns_address, null)
  secondary_dns_address_ipv6_variable = try("{{${each.value.wan_vpn.ipv6_secondary_dns_address_variable}}}", null)
  services = try(length(each.value.wan_vpn.services) == 0, true) ? null : [for service in each.value.wan_vpn.services : {
    service_type = service
  }]
  vpn = 0
}

resource "sdwan_transport_wan_vpn_interface_ethernet_feature" "transport_wan_vpn_interface_ethernet_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for wan_vpn in try([profile.wan_vpn], []) : [
          for interface in try(wan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            wan_vpn   = wan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-wan_vpn-${interface_item.interface.name}" => interface_item
  }
  name                         = each.value.interface.name
  description                  = try(each.value.interface.description, null)
  feature_profile_id           = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_wan_vpn_feature_id = sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${each.value.profile.name}-wan_vpn"].id
  acl_ipv4_egress_feature_id   = null # to be added when ACL is supported
  acl_ipv4_ingress_feature_id  = null # to be added when ACL is supported
  acl_ipv6_egress_feature_id   = null # to be added when ACL is supported
  acl_ipv6_ingress_feature_id  = null # to be added when ACL is supported
  arp_timeout                  = try(each.value.interface.arp_timeout, null)
  arp_timeout_variable         = try("{{${each.value.interface.arp_timeout_variable}}}", null)
  arps = try(length(each.value.interface.arp_entries) == 0, true) ? null : [for arp in each.value.interface.arp_entries : {
    ip_address           = try(arp.ip_address, null)
    ip_address_variable  = try("{{${arp.ip_address_variable}}}", null)
    mac_address          = try(arp.mac_address, null)
    mac_address_variable = try("{{${arp.mac_address_variable}}}", null)
  }]
  auto_detect_bandwidth          = try(each.value.interface.auto_detect_bandwidth, null)
  auto_detect_bandwidth_variable = try("{{${each.value.interface.auto_detect_bandwidth_variable}}}", null)
  autonegotiate                  = try(each.value.interface.autonegotiate, null)
  autonegotiate_variable         = try("{{${each.value.interface.autonegotiate_variable}}}", null)
  bandwidth_downstream           = try(each.value.interface.bandwidth_downstream, null)
  bandwidth_downstream_variable  = try("{{${each.value.interface.bandwidth_downstream_variable}}}", null)
  bandwidth_upstream             = try(each.value.interface.bandwidth_upstream, null)
  bandwidth_upstream_variable    = try("{{${each.value.interface.bandwidth_upstream_variable}}}", null)
  block_non_source_ip            = try(each.value.interface.block_non_source_ip, null)
  block_non_source_ip_variable   = try("{{${each.value.interface.block_non_source_ip_variable}}}", null)
  duplex                         = try(each.value.interface.duplex, null)
  duplex_variable                = try("{{${each.value.interface.duplex_variable}}}", null)
  enable_dhcpv6                  = try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.ipv6_configuration_type) == "dynamic" ? true : null
  gre_tunnel_source_ip           = try(each.value.interface.gre_tloc_extension_source_ip, null)
  gre_tunnel_source_ip_variable  = try("{{${each.value.interface.gre_tloc_extension_source_ip_variable}}}", null)
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
  iperf_server                   = try(each.value.interface.iperf_server, null)
  iperf_server_variable          = try("{{${each.value.interface.iperf_server_variable}}}", null)
  ipv4_address                   = try(each.value.interface.ipv4_address, null)
  ipv4_address_variable          = try("{{${each.value.interface.ipv4_address_variable}}}", null)
  ipv4_configuration_type        = try(each.value.interface.ipv4_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.ipv4_configuration_type)
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
  ipv6_address              = try(each.value.interface.ipv6_address, null)
  ipv6_address_variable     = try("{{${each.value.interface.ipv6_address_variable}}}", null)
  ipv6_configuration_type   = try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.ipv6_configuration_type)
  ipv6_dhcp_secondary_address = try(try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.ipv6_configuration_type) == "dynamic" && length(each.value.interface.ipv6_secondary_addresses) > 0, false) ? [for a in each.value.interface.ipv6_secondary_addresses : {
    address          = try(a.address, null)
    address_variable = try("{{${a.address_variable}}}", null)
  }] : null
  ipv6_secondary_addresses = try(try(each.value.interface.ipv6_configuration_type, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.ipv6_configuration_type) == "static" && length(each.value.interface.ipv6_secondary_addresses) > 0, false) ? [for a in each.value.interface.ipv6_secondary_addresses : {
    address          = try(a.address, null)
    address_variable = try("{{${a.address_variable}}}", null)
  }] : null
  load_interval              = try(each.value.interface.load_interval, null)
  load_interval_variable     = try("{{${each.value.interface.load_interval_variable}}}", null)
  mac_address                = try(each.value.interface.mac_address, null)
  mac_address_variable       = try("{{${each.value.interface.mac_address_variable}}}", null)
  media_type                 = try(each.value.interface.media_type, null)
  media_type_variable        = try("{{${each.value.interface.media_type_variable}}}", null)
  nat64                      = try(each.value.interface.ipv6_nat_type == "nat64", null)
  nat66                      = try(each.value.interface.ipv6_nat_type == "nat66", null)
  nat_ipv4                   = try(each.value.interface.ipv4_nat, null)
  nat_ipv4_variable          = try("{{${each.value.interface.ipv4_nat_variable}}}", null)
  nat_ipv6                   = try(each.value.interface.ipv6_nat, null)
  nat_ipv6_variable          = try("{{${each.value.interface.ipv6_nat_variable}}}", null)
  nat_loopback               = try(each.value.interface.ipv4_nat_loopback_interface, null)
  nat_loopback_variable      = try("{{${each.value.interface.ipv4_nat_loopback_interface_variable}}}", null)
  nat_overload               = try(each.value.interface.ipv4_nat_pool_overload, null)
  nat_overload_variable      = try("{{${each.value.interface.ipv4_nat_pool_overload_variable}}}", null)
  nat_prefix_length          = try(each.value.interface.ipv4_nat_pool_prefix_length, null)
  nat_prefix_length_variable = try("{{${each.value.interface.ipv4_nat_pool_prefix_length_variable}}}", null)
  nat_range_end              = try(each.value.interface.ipv4_nat_pool_range_end, null)
  nat_range_end_variable     = try("{{${each.value.interface.ipv4_nat_pool_range_end_variable}}}", null)
  nat_range_start            = try(each.value.interface.ipv4_nat_pool_range_start, null)
  nat_range_start_variable   = try("{{${each.value.interface.ipv4_nat_pool_range_start_variable}}}", null)
  nat_tcp_timeout            = try(each.value.interface.ipv4_nat_tcp_timeout, null)
  nat_tcp_timeout_variable   = try("{{${each.value.interface.ipv4_nat_tcp_timeout_variable}}}", null)
  nat_udp_timeout            = try(each.value.interface.ipv4_nat_udp_timeout, null)
  nat_udp_timeout_variable   = try("{{${each.value.interface.ipv4_nat_udp_timeout_variable}}}", null)
  nat_type                   = try(each.value.interface.ipv4_nat_type, null)
  nat_type_variable          = try("{{${each.value.interface.ipv4_nat_type_variable}}}", null)
  new_static_nats = try(length(each.value.interface.ipv4_nat_static_entries) == 0, true) ? null : [for nat in each.value.interface.ipv4_nat_static_entries : {
    direction              = try(nat.direction, null)
    source_ip              = try(nat.source_ip, null)
    source_ip_variable     = try("{{${nat.source_ip_variable}}}", null)
    source_vpn             = try(nat.source_vpn_id, null)
    source_vpn_variable    = try("{{${nat.source_vpn_id_variable}}}", null)
    translated_ip          = try(nat.translate_ip, null)
    translated_ip_variable = try("{{${nat.translate_ip_variable}}}", null)
  }]
  per_tunnel_qos                           = try(each.value.interface.tunnel_interface.per_tunnel_qos, null)
  per_tunnel_qos_variable                  = try("{{${each.value.interface.tunnel_interface.per_tunnel_qos_variable}}}", null)
  qos_adaptive                             = try(each.value.interface.adaptive_qos, false)
  qos_adaptive_bandwidth_downstream        = try(each.value.interface.adaptive_qos_shaping_rate_downstream != null, null)
  qos_adaptive_bandwidth_upstream          = try(each.value.interface.adaptive_qos_shaping_rate_upstream != null, null)
  qos_adaptive_default_downstream          = try(each.value.interface.adaptive_qos_shaping_rate_downstream.default, null)
  qos_adaptive_default_downstream_variable = try("{{${each.value.interface.adaptive_qos_shaping_rate_downstream.default_variable}}}", null)
  qos_adaptive_default_upstream            = try(each.value.interface.adaptive_qos_shaping_rate_upstream.default, null)
  qos_adaptive_default_upstream_variable   = try("{{${each.value.interface.adaptive_qos_shaping_rate_upstream.default_variable}}}", null)
  qos_adaptive_max_downstream              = try(each.value.interface.adaptive_qos_shaping_rate_downstream.maximum, null)
  qos_adaptive_max_downstream_variable     = try("{{${each.value.interface.adaptive_qos_shaping_rate_downstream.maximum_variable}}}", null)
  qos_adaptive_max_upstream                = try(each.value.interface.adaptive_qos_shaping_rate_upstream.maximum, null)
  qos_adaptive_max_upstream_variable       = try("{{${each.value.interface.adaptive_qos_shaping_rate_upstream.maximum_variable}}}", null)
  qos_adaptive_min_downstream              = try(each.value.interface.adaptive_qos_shaping_rate_downstream.minimum, null)
  qos_adaptive_min_downstream_variable     = try("{{${each.value.interface.adaptive_qos_shaping_rate_downstream.minimum_variable}}}", null)
  qos_adaptive_min_upstream                = try(each.value.interface.adaptive_qos_shaping_rate_upstream.minimum, null)
  qos_adaptive_min_upstream_variable       = try("{{${each.value.interface.adaptive_qos_shaping_rate_upstream.minimum_variable}}}", null)
  qos_adaptive_period                      = try(each.value.interface.adaptive_qos_period, null)
  qos_adaptive_period_variable             = try("{{${each.value.interface.adaptive_qos_period_variable}}}", null)
  qos_shaping_rate                         = try(each.value.interface.shaping_rate, null)
  qos_shaping_rate_variable                = try("{{${each.value.interface.shaping_rate_variable}}}", null)
  service_provider                         = try(each.value.interface.service_provider, null)
  service_provider_variable                = try("{{${each.value.interface.service_provider_variable}}}", null)
  shutdown                                 = try(each.value.interface.shutdown, null)
  shutdown_variable                        = try("{{${each.value.interface.shutdown_variable}}}", null)
  speed                                    = try(each.value.interface.speed, null)
  speed_variable                           = try("{{${each.value.interface.speed_variable}}}", null)
  static_nat66 = try(length(each.value.interface.ipv6_nat66_static_entries) == 0, true) ? null : [for nat in each.value.interface.ipv6_nat66_static_entries : {
    source_prefix                     = try(nat.source_prefix, null)
    source_prefix_variable            = try("{{${nat.source_prefix_variable}}}", null)
    source_vpn_id                     = try(nat.source_vpn_id, null)
    source_vpn_id_variable            = try("{{${nat.source_vpn_id_variable}}}", null)
    translated_source_prefix          = try(nat.translate_prefix, null)
    translated_source_prefix_variable = try("{{${nat.translate_prefix_variable}}}", null)
  }]
  tcp_mss                           = try(each.value.interface.tcp_mss, null)
  tcp_mss_variable                  = try("{{${each.value.interface.tcp_mss_variable}}}", null)
  tloc_extension                    = try(each.value.interface.tloc_extension, null)
  tloc_extension_variable           = try("{{${each.value.interface.tloc_extension_variable}}}", null)
  tunnel_bandwidth_percent          = try(each.value.interface.tunnel_interface.per_tunnel_qos_bandwidth_percent, null)
  tunnel_bandwidth_percent_variable = try("{{${each.value.interface.tunnel_interface.per_tunnel_qos_bandwidth_percent_variable}}}", null)
  tunnel_interface                  = try(each.value.interface.tunnel_interface != null, null)
  tunnel_interface_encapsulations = try(each.value.interface.tunnel_interface == null, true) ? null : flatten([
    try(each.value.interface.tunnel_interface.ipsec_encapsulation, local.defaults.sdwan.feature_profiles.transport_profiles.wan_vpn.ethernet_interfaces.tunnel_interface.ipsec_encapsulation) ? [{
      encapsulation       = "ipsec"
      preference          = try(each.value.interface.tunnel_interface.ipsec_preference, null)
      preference_variable = try("{{${each.value.interface.tunnel_interface.ipsec_preference_variable}}}", null)
      weight              = try(each.value.interface.tunnel_interface.ipsec_weight, null)
      weight_variable     = try("{{${each.value.interface.tunnel_interface.ipsec_weight_variable}}}", null)
    }] : [],
    try(each.value.interface.tunnel_interface.gre_encapsulation, false) ? [{
      encapsulation       = "gre"
      preference          = try(each.value.interface.tunnel_interface.gre_preference, null)
      preference_variable = try("{{${each.value.interface.tunnel_interface.gre_preference_variable}}}", null)
      weight              = try(each.value.interface.tunnel_interface.gre_weight, null)
      weight_variable     = try("{{${each.value.interface.tunnel_interface.gre_weight_variable}}}", null)
    }] : []
  ])
  tunnel_interface_allow_all                              = try(each.value.interface.tunnel_interface.allow_service_all, null)
  tunnel_interface_allow_all_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_all_variable}}}", null)
  tunnel_interface_allow_bfd                              = try(each.value.interface.tunnel_interface.allow_service_bfd, null)
  tunnel_interface_allow_bfd_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_bfd_variable}}}", null)
  tunnel_interface_allow_bgp                              = try(each.value.interface.tunnel_interface.allow_service_bgp, null)
  tunnel_interface_allow_bgp_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_bgp_variable}}}", null)
  tunnel_interface_allow_dhcp                             = try(each.value.interface.tunnel_interface.allow_service_dhcp, null)
  tunnel_interface_allow_dhcp_variable                    = try("{{${each.value.interface.tunnel_interface.allow_service_dhcp_variable}}}", null)
  tunnel_interface_allow_dns                              = try(each.value.interface.tunnel_interface.allow_service_dns, null)
  tunnel_interface_allow_dns_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_dns_variable}}}", null)
  tunnel_interface_allow_https                            = try(each.value.interface.tunnel_interface.allow_service_https, null)
  tunnel_interface_allow_https_variable                   = try("{{${each.value.interface.tunnel_interface.allow_service_https_variable}}}", null)
  tunnel_interface_allow_icmp                             = try(each.value.interface.tunnel_interface.allow_service_icmp, null)
  tunnel_interface_allow_icmp_variable                    = try("{{${each.value.interface.tunnel_interface.allow_service_icmp_variable}}}", null)
  tunnel_interface_allow_netconf                          = try(each.value.interface.tunnel_interface.allow_service_netconf, null)
  tunnel_interface_allow_netconf_variable                 = try("{{${each.value.interface.tunnel_interface.allow_service_netconf_variable}}}", null)
  tunnel_interface_allow_ntp                              = try(each.value.interface.tunnel_interface.allow_service_ntp, null)
  tunnel_interface_allow_ntp_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_ntp_variable}}}", null)
  tunnel_interface_allow_ospf                             = try(each.value.interface.tunnel_interface.allow_service_ospf, null)
  tunnel_interface_allow_ospf_variable                    = try("{{${each.value.interface.tunnel_interface.allow_service_ospf_variable}}}", null)
  tunnel_interface_allow_snmp                             = try(each.value.interface.tunnel_interface.allow_service_snmp, null)
  tunnel_interface_allow_snmp_variable                    = try("{{${each.value.interface.tunnel_interface.allow_service_snmp_variable}}}", null)
  tunnel_interface_allow_ssh                              = try(each.value.interface.tunnel_interface.allow_service_ssh, null)
  tunnel_interface_allow_ssh_variable                     = try("{{${each.value.interface.tunnel_interface.allow_service_ssh_variable}}}", null)
  tunnel_interface_allow_stun                             = try(each.value.interface.tunnel_interface.allow_service_stun, null)
  tunnel_interface_allow_stun_variable                    = try("{{${each.value.interface.tunnel_interface.allow_service_stun_variable}}}", null)
  tunnel_interface_bind_loopback_tunnel                   = try(each.value.interface.tunnel_interface.bind_loopback_tunnel, null)
  tunnel_interface_bind_loopback_tunnel_variable          = try("{{${each.value.interface.tunnel_interface.bind_loopback_tunnel_variable}}}", null)
  tunnel_interface_border                                 = try(each.value.interface.tunnel_interface.border, null)
  tunnel_interface_border_variable                        = try("{{${each.value.interface.tunnel_interface.border_variable}}}", null)
  tunnel_interface_carrier                                = try(each.value.interface.tunnel_interface.carrier, null)
  tunnel_interface_carrier_variable                       = try("{{${each.value.interface.tunnel_interface.carrier_variable}}}", null)
  tunnel_interface_clear_dont_fragment                    = try(each.value.interface.tunnel_interface.clear_dont_fragment, null)
  tunnel_interface_clear_dont_fragment_variable           = try("{{${each.value.interface.tunnel_interface.clear_dont_fragment_variable}}}", null)
  tunnel_interface_color                                  = try(each.value.interface.tunnel_interface.color, null)
  tunnel_interface_color_restrict                         = try(each.value.interface.tunnel_interface.restrict, null)
  tunnel_interface_color_restrict_variable                = try("{{${each.value.interface.tunnel_interface.restrict_variable}}}", null)
  tunnel_interface_color_variable                         = try("{{${each.value.interface.tunnel_interface.color_variable}}}", null)
  tunnel_interface_cts_sgt_propagation                    = try(each.value.interface.tunnel_interface.cts_sgt_propagation, null)
  tunnel_interface_cts_sgt_propagation_variable           = try("{{${each.value.interface.tunnel_interface.cts_sgt_propagation_variable}}}", null)
  tunnel_interface_exclude_controller_group_list          = try(each.value.interface.tunnel_interface.exclude_controller_groups, null)
  tunnel_interface_exclude_controller_group_list_variable = try("{{${each.value.interface.tunnel_interface.exclude_controller_groups_variable}}}", null)
  tunnel_interface_gre_tunnel_destination_ip              = try(each.value.interface.tunnel_interface.gre_tunnel_destination_ip, null)
  tunnel_interface_gre_tunnel_destination_ip_variable     = try("{{${each.value.interface.tunnel_interface.gre_tunnel_destination_ip_variable}}}", null)
  tunnel_interface_groups                                 = try(each.value.interface.tunnel_interface.group, null)
  tunnel_interface_groups_variable                        = try("{{${each.value.interface.tunnel_interface.group_variable}}}", null)
  tunnel_interface_hello_interval                         = try(each.value.interface.tunnel_interface.hello_interval, null)
  tunnel_interface_hello_interval_variable                = try("{{${each.value.interface.tunnel_interface.hello_interval_variable}}}", null)
  tunnel_interface_hello_tolerance                        = try(each.value.interface.tunnel_interface.hello_tolerance, null)
  tunnel_interface_hello_tolerance_variable               = try("{{${each.value.interface.tunnel_interface.hello_tolerance_variable}}}", null)
  tunnel_interface_last_resort_circuit                    = try(each.value.interface.tunnel_interface.last_resort_circuit, null)
  tunnel_interface_last_resort_circuit_variable           = try("{{${each.value.interface.tunnel_interface.last_resort_circuit_variable}}}", null)
  tunnel_interface_low_bandwidth_link                     = try(each.value.interface.tunnel_interface.low_bandwidth_link, null)
  tunnel_interface_low_bandwidth_link_variable            = try("{{${each.value.interface.tunnel_interface.low_bandwidth_link_variable}}}", null)
  tunnel_interface_max_control_connections                = try(each.value.interface.tunnel_interface.max_control_connections, null)
  tunnel_interface_max_control_connections_variable       = try("{{${each.value.interface.tunnel_interface.max_control_connections_variable}}}", null)
  tunnel_interface_nat_refresh_interval                   = try(each.value.interface.tunnel_interface.nat_refresh_interval, null)
  tunnel_interface_nat_refresh_interval_variable          = try("{{${each.value.interface.tunnel_interface.nat_refresh_interval_variable}}}", null)
  tunnel_interface_network_broadcast                      = try(each.value.interface.tunnel_interface.network_broadcast, null)
  tunnel_interface_network_broadcast_variable             = try("{{${each.value.interface.tunnel_interface.network_broadcast_variable}}}", null)
  tunnel_interface_port_hop                               = try(each.value.interface.tunnel_interface.port_hop, null)
  tunnel_interface_port_hop_variable                      = try("{{${each.value.interface.tunnel_interface.port_hop_variable}}}", null)
  tunnel_interface_tunnel_tcp_mss                         = try(each.value.interface.tunnel_interface.tcp_mss, null)
  tunnel_interface_tunnel_tcp_mss_variable                = try("{{${each.value.interface.tunnel_interface.tcp_mss_variable}}}", null)
  tunnel_interface_vbond_as_stun_server                   = try(each.value.interface.tunnel_interface.vbond_as_stun_server, null)
  tunnel_interface_vbond_as_stun_server_variable          = try("{{${each.value.interface.tunnel_interface.vbond_as_stun_server_variable}}}", null)
  tunnel_interface_vmanage_connection_preference          = try(each.value.interface.tunnel_interface.vmanage_connection_preference, null)
  tunnel_interface_vmanage_connection_preference_variable = try("{{${each.value.interface.tunnel_interface.vmanage_connection_preference_variable}}}", null)
  tunnel_qos_mode                                         = try(each.value.interface.tunnel_interface.per_tunnel_qos_mode, null)
  tunnel_qos_mode_variable                                = try("{{${each.value.interface.tunnel_interface.per_tunnel_qos_mode_variable}}}", null)
  xconnect                                                = try(each.value.interface.gre_tloc_extension_xconnect, null)
  xconnect_variable                                       = try("{{${each.value.interface.gre_tloc_extension_xconnect_variable}}}", null)
}

resource "sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature" "transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for wan_vpn in try([profile.wan_vpn], []) : [
          for interface in try(wan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            wan_vpn   = wan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-wan_vpn-${interface_item.interface.name}-tracker" => interface_item
    if try(interface_item.interface.ipv4_tracker, null) != null
  }
  feature_profile_id                              = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_wan_vpn_feature_id                    = sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${each.value.profile.name}-wan_vpn"].id
  transport_wan_vpn_interface_ethernet_feature_id = sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${each.value.profile.name}-wan_vpn-${each.value.interface.name}"].id
  transport_tracker_feature_id                    = sdwan_transport_tracker_feature.transport_tracker_feature["${each.value.profile.name}-${each.value.interface.ipv4_tracker}"].id
}

resource "sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature" "transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for wan_vpn in try([profile.wan_vpn], []) : [
          for interface in try(wan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            wan_vpn   = wan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-wan_vpn-${interface_item.interface.name}-trackergroup" => interface_item
    if try(interface_item.interface.ipv4_tracker_group, null) != null
  }
  feature_profile_id                              = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_wan_vpn_feature_id                    = sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${each.value.profile.name}-wan_vpn"].id
  transport_wan_vpn_interface_ethernet_feature_id = sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${each.value.profile.name}-wan_vpn-${each.value.interface.name}"].id
  transport_tracker_group_feature_id              = sdwan_transport_tracker_group_feature.transport_tracker_group_feature["${each.value.profile.name}-${each.value.interface.ipv4_tracker_group}"].id
}

resource "sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature" "transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for wan_vpn in try([profile.wan_vpn], []) : [
          for interface in try(wan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            wan_vpn   = wan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-wan_vpn-${interface_item.interface.name}-ipv6_tracker" => interface_item
    if try(interface_item.interface.ipv6_tracker, null) != null
  }
  feature_profile_id                              = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_wan_vpn_feature_id                    = sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${each.value.profile.name}-wan_vpn"].id
  transport_wan_vpn_interface_ethernet_feature_id = sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${each.value.profile.name}-wan_vpn-${each.value.interface.name}"].id
  transport_ipv6_tracker_feature_id               = sdwan_transport_ipv6_tracker_feature.transport_ipv6_tracker_feature["${each.value.profile.name}-${each.value.interface.ipv6_tracker}"].id
}

resource "sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature" "transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature" {
  for_each = {
    for interface_item in flatten([
      for profile in try(local.feature_profiles.transport_profiles, {}) : [
        for wan_vpn in try([profile.wan_vpn], []) : [
          for interface in try(wan_vpn.ethernet_interfaces, []) : {
            profile   = profile
            wan_vpn   = wan_vpn
            interface = interface
          }
        ]
      ]
    ])
    : "${interface_item.profile.name}-wan_vpn-${interface_item.interface.name}-ipv6_trackergroup" => interface_item
    if try(interface_item.interface.ipv6_tracker_group, null) != null
  }
  feature_profile_id                              = sdwan_transport_feature_profile.transport_feature_profile[each.value.profile.name].id
  transport_wan_vpn_feature_id                    = sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${each.value.profile.name}-wan_vpn"].id
  transport_wan_vpn_interface_ethernet_feature_id = sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${each.value.profile.name}-wan_vpn-${each.value.interface.name}"].id
  transport_ipv6_tracker_group_feature_id         = sdwan_transport_ipv6_tracker_group_feature.transport_ipv6_tracker_group_feature["${each.value.profile.name}-${each.value.interface.ipv6_tracker_group}"].id
}
