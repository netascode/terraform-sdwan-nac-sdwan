
resource "sdwan_configuration_group" "configuration_group" {
  for_each    = { for g in local.configuration_groups : g.name => g }
  name        = each.value.name
  description = try(each.value.description, "")
  solution    = "sdwan"
  feature_profiles = flatten([
    try(each.value.cli_profile, null) == null ? [] : [{
      id = sdwan_cli_feature_profile.cli_feature_profile[each.value.cli_profile].id
    }],
    try(each.value.other_profile, null) == null ? [] : [{
      id = sdwan_other_feature_profile.other_feature_profile[each.value.other_profile].id
    }],
    try(each.value.service_profile, null) == null ? [] : [{
      id = sdwan_service_feature_profile.service_feature_profile[each.value.service_profile].id
    }],
    try(each.value.system_profile, null) == null ? [] : [{
      id = sdwan_system_feature_profile.system_feature_profile[each.value.system_profile].id
    }],
    try(each.value.transport_profile, null) == null ? [] : [{
      id = sdwan_transport_feature_profile.transport_feature_profile[each.value.transport_profile].id
    }],
    try(each.value.policy_object_profile, null) == null ? [] : [{
      id = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
    }]
  ])
  devices = [
    for router in local.routers : {
      id     = router.chassis_id
      deploy = try(router.configuration_group_deploy, local.defaults.sdwan.sites.routers.configuration_group_deploy)
      variables = try(length(router.device_variables) == 0, true) ? null : [for name, value in router.device_variables : {
        name       = name
        value      = can(value[0]) ? null : value
        value_list = can(value[0]) ? value : null
      }]
    } if router.configuration_group == each.value.name
  ]
  feature_versions = flatten([
    try(each.value.cli_profile, null) == null ? [] : local.cli_profile_features_versions[each.value.cli_profile],
    try(each.value.other_profile, null) == null ? [] : local.other_profile_features_version[each.value.other_profile],
    try(each.value.service_profile, null) == null ? [] : local.service_profile_features_versions[each.value.service_profile],
    try(each.value.system_profile, null) == null ? [] : local.system_profile_features_versions[each.value.system_profile],
    try(each.value.transport_profile, null) == null ? [] : local.transport_profile_features_versions[each.value.transport_profile],
    try(each.value.policy_object_profile, null) == null ? [] : [local.feature_profiles.policy_object_profile.version]
  ])
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
  other_profile_features_version = {
    for profile in try(local.feature_profiles.other_profiles, []) : profile.name => flatten([
      try(profile.thousandeyes, null) == null ? [] : [sdwan_other_thousandeyes_feature.other_thousandeyes_feature["${profile.name}-thousandeyes"].version],
      try(profile.ucse, null) == null ? [] : [sdwan_other_ucse_feature.other_ucse_feature["${profile.name}-ucse"].version],
    ])
  }
  service_profile_features_versions = {
    for profile in try(local.feature_profiles.service_profiles, []) : profile.name => flatten([
      try(profile.ipv4_tracker_groups, null) == null ? [] : [for ipv4_tracker_group in try(profile.ipv4_tracker_groups, []) : [
        sdwan_service_tracker_group_feature.service_tracker_group_feature["${profile.name}-${ipv4_tracker_group.name}"].version
      ]],
      try(profile.ipv4_trackers, null) == null ? [] : [for ipv4_tracker in try(profile.ipv4_trackers, []) : [
        sdwan_service_tracker_feature.service_tracker_feature["${profile.name}-${ipv4_tracker.name}"].version
      ]],
      try(profile.object_tracker_groups, null) == null ? [] : [for object_tracker_group in try(profile.object_tracker_groups, []) : [
        sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature["${profile.name}-${object_tracker_group.name}"].version
      ]],
      try(profile.object_trackers, null) == null ? [] : [for object_tracker in try(profile.object_trackers, []) : [
        sdwan_service_object_tracker_feature.service_object_tracker_feature["${profile.name}-${object_tracker.name}"].version
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
      try(profile.ipv4_tracker_group, null) == null ? [] : [for ipv4_tracker_group in try(profile.ipv4_tracker_group, []) : [
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
      try(profile.wan_vpn, null) == null ? [] : [sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature["${profile.name}-wan_vpn"].version],
      try(profile.wan_vpn.ethernet_interfaces, null) == null ? [] : [for interface in try(profile.wan_vpn.ethernet_interfaces, []) : [
        sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature["${profile.name}-wan_vpn-${interface.name}"].version,
        # try(interface.ipv4_tracker, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature["${profile.name}-wan_vpn-${interface.name}-tracker"].version],
        # try(interface.ipv4_tracker_group, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature["${profile.name}-wan_vpn-${interface.name}-trackergroup"].version],
        # try(interface.ipv6_tracker, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature["${profile.name}-wan_vpn-${interface.name}-ipv6_tracker"].version],
        # try(interface.ipv6_tracker_group, null) == null ? [] : [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature["${profile.name}-wan_vpn-${interface.name}-ipv6_trackergroup"].version],
      ]],
    ])
  }
}
