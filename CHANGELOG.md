## 1.4.0 (unreleased)

- move device types to defaults for SIG credentials feature template
- rename `traffic_class` to `traffic_classes` in both transport and service IPv6 ACL match actions
- add support for policy object security data IP prefix
- add support for policy object security fqdn list
- add support for policy object security ips signature list
- add support for policy object security local application list
- add support for policy object security port list
- add support for policy object security protocol list
- add support for policy object security url allow list
- add support for policy object security url block list
- add support for policy object security Advanced Malware Protection Profile
- add support for policy object security Intrusion Prevention Profile
- add support for service OSPFv3 IPv6
- add support for service Multicast
- add support for `cloud_qos` and `cloud_qos_service_side` in `sdwan_localized_policy`
- add `topology_label` attribute to configuration group
- fix service bgp and transport bgp failing when ipv6 neighbor has `maximum_prefix_reach_policy` set to `off`
- fix nat fallback default behaviour in centralized data policy
- fix match region_id bug in custom control policy
- add support for policy object security geolocation list
- add support for UX 2.0 MRF in versions 20.13 and higher
- align `cisco_sig_credentials_feature_template` device types creation logic with other features
- add support for `policy_version` in `sdwan_zone_based_firewall_policy_definition`
- add support for system CA certificate feature
- add support for application priority traffic policy
- add support for new 20.15 service LAN VPN attributes
- fix an issue where the `route_policy_variable` was not being correctly applied in `sdwan_cisco_ospf_feature_template`
- fix an issue where the SIG `fallback_to_routing` set to false was still getting applied in `sdwan_traffic_data_policy_definition`

## 1.3.0

- add support for application priority feature profile
- add support for application priority qos policy
- add support for policy groups
- add support for policy object color list
- add support for policy object preferred color group
- add support for policy object SLA class
- add support for service BGP
- add support for service EIGRP
- add support for service IPv4 ACL
- add support for service IPv6 ACL
- add support for service LAN VPN Ethernet Interface
- add support for service OSPF
- add support for transport BGP
- add support for transport IPv4 ACL
- add support for transport IPv6 ACL
- add support for transport OSPF
- add support for UX 1.0 PIM feature template
- add support for UX 1.0 policy object port list
- add support for UX 1.0 unified security policy and unified firewall
- add support for `default_action` in UX 1.0 application aware routing policy
- add support for queue 0 in UX 1.0 QoS Map which contains no class map id
- add support for `enhanced_app_aware_routing_variable` parameter in system feature template
- rename LAN VPN etherent interface DHCP server association from `...dhcp` to `...dhcp_server`
- remove `secret_key` from `tacacs` and `radius` server configuration in AAA feature
- fix `backup_interface` to consider `none` as `None` in Secure Internet Gateway feature template
- fix logging_feature_template `custom_profile` attribute logic (`null` in case tls_profile is not configured)
- fix route policy `standard_community_lists` to properly handle both single and multiple community list entries
- fix `trunk_allowed_vlans_variable` not being set correctly in switchport feature template
- use default names `Cisco-Umbrella-Global-Credentials` and `Cisco-Zscaler-Global-Credentials` for SIG credentials feature template
- fix `vpn_name_variable` not being set in VPN feature template
- fix vpn feature template service route failing during device template push
- move UX 1.0 route policy sequence name from hardcoded value to defaults

## 1.2.0

- add support for UX 1.0 IGMP feature template
- add support for UX 1.0 multicast feature template
- add support for service LAN VPN feature
- add support for service route policy
- add support for transport cellular profile
- add support for transport GPS
- add support for transport route policy
- add support for policy object application list
- add support for policy object app probe class
- add default handling of `ip_type` in UX 1.0 route policy
- add `expanded_community_list_variable` parameter in UX 1.0 route policy
- add `destination_ip_prefix_variable` and `source_ip_prefix_variable` parameters support in UX 1.0 IPv4 acl policy IPv6 device acl policy
- add `enhanced_app_aware_routing` parameter support in UX 1.0 system feature template
- fix `local_tloc_list` `encaps` parameter to be optional in UX 1.0 traffic data policy
- fix `nat_pool` action not being set correctly in UX 1.0 traffic data policy
- fix `sdwan_attach_feature_device_template` resource to be generated per template, not per device
- fix `devices` and `feature_versions` parameters of configuration group to be null when empty
- fix `id` parameter in system IPv4 device access and IPv6 device access features
- fix `administrative_distance_variable` parameter not being set in the transport management VPN feature
- fix UX 2.0 enum values to be lowercase wherever possible

## 1.1.0

- fix vty_line_logging parameter not being set in sdwan_system_global_feature
- add support for sdwan_policy_object_as_path_list resource
- add support for sdwan_policy_object_standard_community_list resource
- fix ipv4_dhcp_helpers_variable not being set when configuring sdwan_transport_management_vpn_interface_ethernet_feature and sdwan_transport_wan_vpn_interface_ethernet_feature
- change sdwan_transport_wan_vpn_interface_ethernet_feature_associateX_feature resources names to match name logic
- fix dhcp parameter logic for sdwan_cisco_vpn_interface_feature_template
- fix VRRP prefix_variable parameter for sdwan_cisco_vpn_interface_feature_template and sdwan_vpn_interface_svi_feature_template
- fix ascii_variable parameter for sdwan_cisco_dhcp_server_feature_template
- add support for sdwan_system_ipv4_device_access_feature resource
- add support for sdwan_system_ipv6_device_access_feature resource
- add support for sdwan_service_dhcp_server_feature resource
- add support for sdwan_configuration_group resource
- add support for sdwan_tag resource

## 1.0.0

- provide default value for name if not explicitly set for sdwan_system_basic_feature, sdwan_system_omp_feature, sdwan_system_performance_monitoring_feature, sdwan_system_security_feature, sdwan_system_snmp_feature and sdwan_transport_wan_vpn_feature
- simplify default feature name from "profile_name-feature_name" to "feature_name"
- add support for sdwan_policy_object_feature_profile resource
- add support for sdwan_policy_object_class_map resource
- add support for sdwan_policy_object_data_ipv4_prefix_list resource
- add support for sdwan_policy_object_data_ipv6_prefix_list resource
- add support for sdwan_policy_object_expanded_community_list resource
- add support for sdwan_policy_object_extended_community_list resource
- add support for sdwan_policy_object_ipv4_prefix_list resource
- add support for sdwan_policy_object_ipv6_prefix_list resource
- add support for sdwan_policy_object_mirror resource
- add support for sdwan_policy_object_policer resource
- add support for sdwan_policy_object_tloc_list resource
- add support for variables in secure app hosting feature template
- fix issue where sdwan_custom_control_topology_policy_definition always shows diff when match_criterias or actions are not configured in data model
- fix issue where sdwan_traffic_data_policy_definition always shows diff when match_criterias or actions are not configured in data model
- fix issue where sdwan_application_aware_routing_policy_definition always shows diff when match_criterias or actions are not configured in data model
- fix issue where certain parameters were required by sdwan_cflowd_policy_definition resource, but are optional in the UI
- fix issue where authentication_type_variable was not configurable with sdwan_cisco_security_feature_template
- in sdwan_cflowd_policy_definition, fix export_spreading to be optional
- add gateway parameter to ipv6_static_routes of sdwan_transport_wan_vpn_feature
- add support for sdwan_other_ucse_feature resource
- add support for sdwan_transport_management_vpn_feature resource
- add support for sdwan_transport_management_vpn_interface_ethernet_feature resource
- separate "sdwan_profile_parcels.tf" into "sdwan_features_cli.tf", "sdwan_features_other.tf", "sdwan_features_service.tf", "sdwan_features_system.tf" and "sdwan_features_transport.tf"
- rename sdwan_system_performance_monitoring_feature resources from "...-performance_monitor" to "...-perfmonitor"
- add support for sdwan_transport_wan_vpn_ethernet_interface resource
- add support for sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature resource
- add support for sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature resource
- add support for sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature resource
- add support for sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature resource
- add support for sdwan_cellular_controller_feature_template resource
- add support for sdwan_cellular_cedge_profile_feature_template resource
- add support for sdwan_cisco_vpn_interface_gre_feature_template resource
- add support for sdwan_vpn_interface_cellular_feature_template resource

## 0.1.0

- Initial release
