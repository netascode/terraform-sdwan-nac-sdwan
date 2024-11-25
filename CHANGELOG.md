## 0.1.1 (unreleased)

- rename "sdwan_profile_parcels.tf" to "sdwan_features.tf"
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
- add defaults for UX 2.0 feature names
- fix issue where certain parameters were required by sdwan_cflowd_policy_definition resource, but are optional in the UI

## 0.1.0

- Initial release
