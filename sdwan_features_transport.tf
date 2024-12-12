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
      administrative_distance_variable = try("{{${nh.administative_distance_variable}}}", null)
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
      administrative_distance_variable = try("{{${nh.administative_distance_variable}}}", null)
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
  ipv4_dhcp_helper_variable           = try("{{${each.value.interface.ipv4_dhcp_helper_variable}}}", null)
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
