
resource "sdwan_configuration_group" "configuration_group" {
  for_each    = { for g in local.configuration_groups : g.name => g }
  name        = each.value.name
  description = try(each.value.description, "")
  solution    = "sdwan"
  feature_profile_ids = flatten([
    try(each.value.cli_profile, null) == null ? [] : [sdwan_cli_feature_profile.cli_feature_profile[each.value.cli_profile].id],
    try(each.value.other_profile, null) == null ? [] : [sdwan_other_feature_profile.other_feature_profile[each.value.other_profile].id],
    try(each.value.policy_object_profile, null) == null ? [] : [sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id],
    try(each.value.service_profile, null) == null ? [] : [sdwan_service_feature_profile.service_feature_profile[each.value.service_profile].id],
    try(each.value.system_profile, null) == null ? [] : [sdwan_system_feature_profile.system_feature_profile[each.value.system_profile].id],
    try(each.value.transport_profile, null) == null ? [] : [sdwan_transport_feature_profile.transport_feature_profile[each.value.transport_profile].id],
  ])
  devices = length([for router in local.routers : router if router.configuration_group == each.value.name]) == 0 ? null : [
    for router in local.routers : {
      id     = router.chassis_id
      deploy = try(router.configuration_group_deploy, local.defaults.sdwan.sites.routers.configuration_group_deploy)
      variables = try(length(router.device_variables) == 0, true) ? null : [for name, value in router.device_variables : {
        name       = name
        value      = try(tostring(value), null)
        list_value = try(tolist(value), null)
      }]
    } if router.configuration_group == each.value.name
  ]
  feature_versions = length(flatten([
    try(each.value.cli_profile, null) == null ? [] : local.cli_profile_features_versions[each.value.cli_profile],
    try(each.value.other_profile, null) == null ? [] : local.other_profile_features_versions[each.value.other_profile],
    try(each.value.policy_object_profile, null) == null ? [] : local.policy_object_profile_features_versions,
    try(each.value.service_profile, null) == null ? [] : local.service_profile_features_versions[each.value.service_profile],
    try(each.value.system_profile, null) == null ? [] : local.system_profile_features_versions[each.value.system_profile],
    try(each.value.transport_profile, null) == null ? [] : local.transport_profile_features_versions[each.value.transport_profile]
    ])) == 0 ? null : flatten([
    try(each.value.cli_profile, null) == null ? [] : local.cli_profile_features_versions[each.value.cli_profile],
    try(each.value.other_profile, null) == null ? [] : local.other_profile_features_versions[each.value.other_profile],
    try(each.value.policy_object_profile, null) == null ? [] : local.policy_object_profile_features_versions,
    try(each.value.service_profile, null) == null ? [] : local.service_profile_features_versions[each.value.service_profile],
    try(each.value.system_profile, null) == null ? [] : local.system_profile_features_versions[each.value.system_profile],
    try(each.value.transport_profile, null) == null ? [] : local.transport_profile_features_versions[each.value.transport_profile]
  ])
  topology_devices = try(each.value.device_tags, null) == null ? null : [for index, device_tag in try(each.value.device_tags, []) : {
    criteria_attribute = "tag"
    criteria_value     = device_tag.name
    unsupported_features = length(flatten([
      for tag in try(each.value.device_tags, []) :
      [
        for feature in try(tag.features, []) :
        try(local.unsupported_features[each.value.transport_profile][feature], try(local.unsupported_features[each.value.service_profile][feature], null))
        if tag.name != device_tag.name && try(local.unsupported_features[each.value.transport_profile][feature], try(local.unsupported_features[each.value.service_profile][feature], null)) != null
      ]
      ])) == 0 ? null : flatten([
      for tag in try(each.value.device_tags, []) :
      [
        for feature in try(tag.features, []) :
        try(local.unsupported_features[each.value.transport_profile][feature], try(local.unsupported_features[each.value.service_profile][feature], null))
        if tag.name != device_tag.name && try(local.unsupported_features[each.value.transport_profile][feature], try(local.unsupported_features[each.value.service_profile][feature], null)) != null
      ]
    ])
  }]
  topology_site_devices = try(each.value.device_tags, null) == null ? null : 2
  depends_on = [
    sdwan_tag.tag,
    sdwan_policy_object_app_probe_class.policy_object_app_probe_class,
    sdwan_policy_object_application_list.policy_object_application_list,
    sdwan_policy_object_tloc_list.policy_object_tloc_list,
    sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group,
    sdwan_policy_object_sla_class_list.policy_object_sla_class_list
  ]
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  cli_profile_features_versions = {
    for profile in try(local.feature_profiles.cli_profiles, []) : profile.name => flatten([
      try(profile.config, null) == null ? [] : [sdwan_cli_config_feature.cli_config_feature["${profile.name}-config"].version],
    ])
  }
  other_profile_features_versions = {
    for profile in try(local.feature_profiles.other_profiles, []) : profile.name => flatten([
      try(profile.thousandeyes, null) == null ? [] : [sdwan_other_thousandeyes_feature.other_thousandeyes_feature["${profile.name}-thousandeyes"].version],
      try(profile.ucse, null) == null ? [] : [sdwan_other_ucse_feature.other_ucse_feature["${profile.name}-ucse"].version],
    ])
  }
  policy_object_profile_features_versions = flatten([
    try(local.feature_profiles.policy_object_profile.as_path_lists, null) == null ? [] : [for as_path_list in try(local.feature_profiles.policy_object_profile.as_path_lists, []) : [
      sdwan_policy_object_as_path_list.policy_object_as_path_list[as_path_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.class_maps, null) == null ? [] : [for class_map in try(local.feature_profiles.policy_object_profile.class_maps, []) : [
      sdwan_policy_object_class_map.policy_object_class_map[class_map.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.ipv4_data_prefix_lists, null) == null ? [] : [for ipv4_data_prefix_list in try(local.feature_profiles.policy_object_profile.ipv4_data_prefix_lists, []) : [
      sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[ipv4_data_prefix_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.ipv6_data_prefix_lists, null) == null ? [] : [for ipv6_data_prefix_list in try(local.feature_profiles.policy_object_profile.ipv6_data_prefix_lists, []) : [
      sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[ipv6_data_prefix_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.expanded_community_lists, null) == null ? [] : [for expanded_community_list in try(local.feature_profiles.policy_object_profile.expanded_community_lists, []) : [
      sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list[expanded_community_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.extended_community_lists, null) == null ? [] : [for extended_community_list in try(local.feature_profiles.policy_object_profile.extended_community_lists, []) : [
      sdwan_policy_object_extended_community_list.policy_object_extended_community_list[extended_community_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.ipv4_prefix_lists, null) == null ? [] : [for ipv4_prefix_list in try(local.feature_profiles.policy_object_profile.ipv4_prefix_lists, []) : [
      sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list[ipv4_prefix_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.ipv6_prefix_lists, null) == null ? [] : [for ipv6_prefix_list in try(local.feature_profiles.policy_object_profile.ipv6_prefix_lists, []) : [
      sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list[ipv6_prefix_list.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.mirrors, null) == null ? [] : [for mirror in try(local.feature_profiles.policy_object_profile.mirrors, []) : [
      sdwan_policy_object_mirror.policy_object_mirror[mirror.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.policers, null) == null ? [] : [for policer in try(local.feature_profiles.policy_object_profile.policers, []) : [
      sdwan_policy_object_policer.policy_object_policer[policer.name].version,
    ]],
    try(local.feature_profiles.policy_object_profile.standard_community_lists, null) == null ? [] : [for standard_community_list in try(local.feature_profiles.policy_object_profile.standard_community_lists, []) : [
      sdwan_policy_object_standard_community_list.policy_object_standard_community_list[standard_community_list.name].version,
    ]],
  ])
  service_profile_features_versions = {
    for profile in try(local.feature_profiles.service_profiles, []) : profile.name => flatten([
      try(profile.bgp_features, null) == null ? [] : [for bgp_feature in try(profile.bgp_features, []) : [
        sdwan_service_routing_bgp_feature.service_routing_bgp_feature["${profile.name}-${bgp_feature.name}"].version
      ]],
      try(profile.dhcp_servers, null) == null ? [] : [for dhcp_server in try(profile.dhcp_servers, []) : [
        sdwan_service_dhcp_server_feature.service_dhcp_server_feature["${profile.name}-${dhcp_server.name}"].version
      ]],
      try(profile.ipv4_acls, null) == null ? [] : [for ipv4_acl in try(profile.ipv4_acls, []) : [
        sdwan_service_ipv4_acl_feature.service_ipv4_acl_feature["${profile.name}-${ipv4_acl.name}"].version
      ]],
      try(profile.ipv4_tracker_groups, null) == null ? [] : [for ipv4_tracker_group in try(profile.ipv4_tracker_groups, []) : [
        sdwan_service_tracker_group_feature.service_tracker_group_feature["${profile.name}-${ipv4_tracker_group.name}"].version
      ]],
      try(profile.ipv4_trackers, null) == null ? [] : [for ipv4_tracker in try(profile.ipv4_trackers, []) : [
        sdwan_service_tracker_feature.service_tracker_feature["${profile.name}-${ipv4_tracker.name}"].version
      ]],
      try(profile.lan_vpns, null) == null ? [] : [for lan_vpn in try(profile.lan_vpns, []) : [
        sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${profile.name}-${lan_vpn.name}"].version,
        try(lan_vpn.bgp, null) == null ? [] : [sdwan_service_lan_vpn_feature_associate_routing_bgp_feature.service_lan_vpn_feature_associate_routing_bgp_feature["${profile.name}-${lan_vpn.name}-routing_bgp"].version],
        try(lan_vpn.ospf, null) == null ? [] : [sdwan_service_lan_vpn_feature_associate_routing_ospf_feature.service_lan_vpn_feature_associate_routing_ospf_feature["${profile.name}-${lan_vpn.name}-routing_ospf"].version],
      ]],
      try(profile.object_tracker_groups, null) == null ? [] : [for object_tracker_group in try(profile.object_tracker_groups, []) : [
        sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${profile.name}-${object_tracker_group.name}"].version
      ]],
      try(profile.object_trackers, null) == null ? [] : [for object_tracker in try(profile.object_trackers, []) : [
        sdwan_service_object_tracker_feature.service_object_tracker_feature["${profile.name}-${object_tracker.name}"].version
      ]],
      try(profile.ospf_features, null) == null ? [] : [for ospf_feature in try(profile.ospf_features, []) : [
        sdwan_service_routing_ospf_feature.service_routing_ospf_feature["${profile.name}-${ospf_feature.name}"].version
      ]],
      try(profile.route_policies, null) == null ? [] : [for route_policy in try(profile.route_policies, []) : [
        sdwan_service_route_policy_feature.service_route_policy_feature["${profile.name}-${route_policy.name}"].version
      ]],
    ])
  }
  system_profile_features_versions = {
    for profile in try(local.feature_profiles.system_profiles, []) : profile.name => flatten([
      try(profile.aaa, null) == null ? [] : [sdwan_system_aaa_feature.system_aaa_feature["${profile.name}-aaa"].version],
      try(profile.banner, null) == null ? [] : [sdwan_system_banner_feature.system_banner_feature["${profile.name}-banner"].version],
      try(profile.basic, null) == null ? [] : [sdwan_system_basic_feature.system_basic_feature["${profile.name}-basic"].version],
      try(profile.bfd, null) == null ? [] : [sdwan_system_bfd_feature.system_bfd_feature["${profile.name}-bfd"].version],
      try(profile.flexible_port_speed, null) == null ? [] : [sdwan_system_flexible_port_speed_feature.system_flexible_port_speed_feature["${profile.name}-flexible_port_speed"].version],
      try(profile.global, null) == null ? [] : [sdwan_system_global_feature.system_global_feature["${profile.name}-global"].version],
      try(profile.ipv4_device_access_policy, null) == null ? [] : [sdwan_system_ipv4_device_access_feature.system_ipv4_device_access_feature["${profile.name}-ipv4_device_access_policy"].version],
      try(profile.ipv6_device_access_policy, null) == null ? [] : [sdwan_system_ipv6_device_access_feature.system_ipv6_device_access_feature["${profile.name}-ipv6_device_access_policy"].version],
      try(profile.logging, null) == null ? [] : [sdwan_system_logging_feature.system_logging_feature["${profile.name}-logging"].version],
      try(profile.mrf, null) == null ? [] : [sdwan_system_mrf_feature.system_mrf_feature["${profile.name}-mrf"].version],
      try(profile.ntp, null) == null ? [] : [sdwan_system_ntp_feature.system_ntp_feature["${profile.name}-ntp"].version],
      try(profile.omp, null) == null ? [] : [sdwan_system_omp_feature.system_omp_feature["${profile.name}-omp"].version],
      try(profile.performance_monitoring, null) == null ? [] : [sdwan_system_performance_monitoring_feature.system_performance_monitoring_feature["${profile.name}-perfmonitor"].version],
      try(profile.security, null) == null ? [] : [sdwan_system_security_feature.system_security_feature["${profile.name}-security"].version],
      try(profile.snmp, null) == null ? [] : [sdwan_system_snmp_feature.system_snmp_feature["${profile.name}-snmp"].version],
    ])
  }
  transport_profile_features_versions = {
    for profile in try(local.feature_profiles.transport_profiles, []) : profile.name => flatten([
      try(profile.bgp_features, null) == null ? [] : [for bgp_feature in try(profile.bgp_features, []) : [
        sdwan_transport_routing_bgp_feature.transport_routing_bgp_feature["${profile.name}-${bgp_feature.name}"].version
      ]],
      try(profile.cellular_profiles, null) == null ? [] : [for cellular_profile in try(profile.cellular_profiles, []) : [
        sdwan_transport_cellular_profile_feature.transport_cellular_profile_feature["${profile.name}-${cellular_profile.name}"].version
      ]],
      try(profile.gps_features, null) == null ? [] : [for gps_feature in try(profile.gps_features, []) : [
        sdwan_transport_gps_feature.transport_gps_feature["${profile.name}-${gps_feature.name}"].version
      ]],
      try(profile.ipv4_acls, null) == null ? [] : [for ipv4_acl in try(profile.ipv4_acls, []) : [
        sdwan_transport_ipv4_acl_feature.transport_ipv4_acl_feature["${profile.name}-${ipv4_acl.name}"].version
      ]],
      try(profile.ipv4_tracker_groups, null) == null ? [] : [for ipv4_tracker_group in try(profile.ipv4_tracker_groups, []) : [
        sdwan_transport_tracker_group_feature.transport_tracker_group_feature["${profile.name}-${ipv4_tracker_group.name}"].version
      ]],
      try(profile.ipv4_trackers, null) == null ? [] : [for ipv4_tracker in try(profile.ipv4_trackers, []) : [
        sdwan_transport_tracker_feature.transport_tracker_feature["${profile.name}-${ipv4_tracker.name}"].version
      ]],
      try(profile.ipv6_tracker_groups, null) == null ? [] : [for ipv6_tracker_group in try(profile.ipv6_tracker_groups, []) : [
        sdwan_transport_ipv6_tracker_group_feature.transport_ipv6_tracker_group_feature["${profile.name}-${ipv6_tracker_group.name}"].version
      ]],
      try(profile.ipv6_trackers, null) == null ? [] : [for ipv6_tracker in try(profile.ipv6_trackers, []) : [
        sdwan_transport_ipv6_tracker_feature.transport_ipv6_tracker_feature["${profile.name}-${ipv6_tracker.name}"].version
      ]],
      try(profile.management_vpn, null) == null ? [] : [sdwan_transport_management_vpn_feature.transport_management_vpn_feature["${profile.name}-management_vpn"].version],
      try(profile.management_vpn.ethernet_interfaces, null) == null ? [] : [for interface in try(profile.management_vpn.ethernet_interfaces, []) : [
        sdwan_transport_management_vpn_interface_ethernet_feature.transport_management_vpn_interface_ethernet_feature["${profile.name}-management_vpn-${interface.name}"].version
      ]],
      try(profile.route_policies, null) == null ? [] : [for route_policy in try(profile.route_policies, []) : [
        sdwan_transport_route_policy_feature.transport_route_policy_feature["${profile.name}-${route_policy.name}"].version
      ]],
      try(profile.wan_vpn, null) == null ? [] : [sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${profile.name}-wan_vpn"].version],
      try(profile.wan_vpn.bgp, null) == null ? [] : [sdwan_transport_wan_vpn_feature_associate_routing_bgp_feature.transport_wan_vpn_feature_associate_routing_bgp_feature["${profile.name}-wan_vpn-routing_bgp"].version],
      try(profile.wan_vpn.ethernet_interfaces, null) == null ? [] : [for interface in try(profile.wan_vpn.ethernet_interfaces, []) : [
        sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${profile.name}-wan_vpn-${interface.name}"].version,
        try(interface.ipv4_tracker, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature["${profile.name}-wan_vpn-${interface.name}-tracker"].version],
        try(interface.ipv4_tracker_group, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature["${profile.name}-wan_vpn-${interface.name}-trackergroup"].version],
        try(interface.ipv6_tracker, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature["${profile.name}-wan_vpn-${interface.name}-ipv6_tracker"].version],
        try(interface.ipv6_tracker_group, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature["${profile.name}-wan_vpn-${interface.name}-ipv6_trackergroup"].version],
      ]],
    ])
  }

  unsupported_features = merge(
    {
      for profile in try(local.feature_profiles.transport_profiles, []) : profile.name => merge(
        {
          for feature in try(profile.bgp_features, []) : feature.name => {
            parcel_id   = sdwan_transport_routing_bgp_feature.transport_routing_bgp_feature["${profile.name}-${feature.name}"].id
            parcel_type = "routing/bgp"
          }
        },
        {
          for feature in try(profile.route_policies, []) : feature.name => {
            parcel_id   = sdwan_transport_route_policy_feature.transport_route_policy_feature["${profile.name}-${feature.name}"].id
            parcel_type = "route-policy"
          }
        },
        {
          for feature in try(profile.wan_vpn.ethernet_interfaces, []) : feature.name => {
            parcel_id   = sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${profile.name}-wan_vpn-${feature.name}"].id
            parcel_type = "wan/vpn/interface/ethernet"
          }
        },
        # Other transport features to be added when supported
        # {
        #   for feature in try(profile.wan_vpn.gre_interfaces, []) : feature.name => {
        #     parcel_id   = sdwan_transport_wan_vpn_interface_gre_feature.transport_wan_vpn_interface_gre_feature["${profile.name}-wan_vpn-${feature.name}"].id
        #     parcel_type = "wan/vpn/interface/gre"
        #   }
        # }
      )
    },
    # Service profile features
    {
      for profile in try(local.feature_profiles.service_profiles, []) : profile.name => merge(
        {
          for feature in try(profile.bgp_features, []) : feature.name => {
            parcel_id   = sdwan_service_routing_bgp_feature.service_routing_bgp_feature["${profile.name}-${feature.name}"].id
            parcel_type = "routing/bgp"
          }
        },
        {
          for feature in try(profile.lan_vpns, []) : feature.name => {
            parcel_id   = sdwan_service_lan_vpn_feature.service_lan_vpn_feature["${profile.name}-${feature.name}"].id
            parcel_type = "lan/vpn"
          }
        },
        {
          for feature in try(profile.route_policies, []) : feature.name => {
            parcel_id   = sdwan_service_route_policy_feature.service_route_policy_feature["${profile.name}-${feature.name}"].id
            parcel_type = "route-policy"
          }
        }
      )
    }
  )
}
