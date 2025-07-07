## 1.2.0 (unreleased)

- fix administrative_distance_variable parameter not being set in the sdwan_transport_management_vpn_feature
- add support for sdwan_service_route_policy_feature resource
- add support for sdwan_transport_cellular_profile_feature resource
- add support for sdwan_transport_gps_feature resource
- add support for sdwan_transport_route_policy_feature resource
- modify id field in sdwan_system_ipv4_device_access_feature and sdwan_system_ipv6_device_access_feature
- add default handling of ip_type for sdwan_route_policy_definition
- add support for sdwan_service_lan_vpn resource

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
