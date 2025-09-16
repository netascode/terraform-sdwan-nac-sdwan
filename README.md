<!-- BEGIN_TF_DOCS -->
# Terraform Network-as-Code Cisco SD-WAN Module

A Terraform module to configure Cisco SD-WAN.

## Usage

This module supports an inventory driven approach, where a complete SD-WAN configuration or parts of it are either modeled in one or more YAML files or natively using Terraform variables.

## Examples

Configuring a Banner Feature Template using YAML:

#### `banner_feature_template.yaml`

```yaml
sdwan:
  edge_feature_templates:
    banner_templates:
      - name: FT-CEDGE-BANNER-01
        description: Base banner template; support carrier returns
        login: "login banner: new\n"
        motd: "motd banner:\r\nNo message today\n"
```

#### `main.tf`

```hcl
module "sdwan" {
  source  = "netascode/nac-sdwan/sdwan"
  version = "0.1.0"

  yaml_files = ["banner_feature_template.yaml"]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 2.3.0 |
| <a name="requirement_sdwan"></a> [sdwan](#requirement\_sdwan) | >= 0.7.1 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 1.0.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_model"></a> [model](#input\_model) | As an alternative to YAML files, a native Terraform data structure can be provided as well. | `map(any)` | `{}` | no |
| <a name="input_write_default_values_file"></a> [write\_default\_values\_file](#input\_write\_default\_values\_file) | Write all default values to a YAML file. Value is a path pointing to the file to be created. | `string` | `""` | no |
| <a name="input_yaml_directories"></a> [yaml\_directories](#input\_yaml\_directories) | List of paths to YAML directories. | `list(string)` | `[]` | no |
| <a name="input_yaml_files"></a> [yaml\_files](#input\_yaml\_files) | List of paths to YAML files. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_values"></a> [default\_values](#output\_default\_values) | All default values. |
| <a name="output_model"></a> [model](#output\_model) | Full model. |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | >= 2.3.0 |
| <a name="provider_sdwan"></a> [sdwan](#provider\_sdwan) | >= 0.7.1 |
| <a name="provider_utils"></a> [utils](#provider\_utils) | >= 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [local_sensitive_file.defaults](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [sdwan_activate_centralized_policy.activate_centralized_policy](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/activate_centralized_policy) | resource |
| [sdwan_app_probe_class_policy_object.app_probe_class_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/app_probe_class_policy_object) | resource |
| [sdwan_application_aware_routing_policy_definition.application_aware_routing_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/application_aware_routing_policy_definition) | resource |
| [sdwan_application_list_policy_object.application_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/application_list_policy_object) | resource |
| [sdwan_as_path_list_policy_object.as_path_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/as_path_list_policy_object) | resource |
| [sdwan_attach_feature_device_template.attach_feature_device_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/attach_feature_device_template) | resource |
| [sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cedge_aaa_feature_template) | resource |
| [sdwan_cedge_global_feature_template.cedge_global_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cedge_global_feature_template) | resource |
| [sdwan_cedge_igmp_feature_template.cedge_igmp_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cedge_igmp_feature_template) | resource |
| [sdwan_cedge_multicast_feature_template.cedge_multicast_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cedge_multicast_feature_template) | resource |
| [sdwan_cellular_cedge_profile_feature_template.cellular_cedge_profile_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cellular_cedge_profile_feature_template) | resource |
| [sdwan_cellular_controller_feature_template.cellular_controller_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cellular_controller_feature_template) | resource |
| [sdwan_centralized_policy.centralized_policy](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/centralized_policy) | resource |
| [sdwan_cflowd_policy_definition.cflowd_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cflowd_policy_definition) | resource |
| [sdwan_cisco_banner_feature_template.cisco_banner_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_banner_feature_template) | resource |
| [sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_bfd_feature_template) | resource |
| [sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_bgp_feature_template) | resource |
| [sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_dhcp_server_feature_template) | resource |
| [sdwan_cisco_logging_feature_template.cisco_logging_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_logging_feature_template) | resource |
| [sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_ntp_feature_template) | resource |
| [sdwan_cisco_omp_feature_template.cisco_omp_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_omp_feature_template) | resource |
| [sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_ospf_feature_template) | resource |
| [sdwan_cisco_secure_internet_gateway_feature_template.cisco_secure_internet_gateway_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_secure_internet_gateway_feature_template) | resource |
| [sdwan_cisco_security_feature_template.cisco_security_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_security_feature_template) | resource |
| [sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_sig_credentials_feature_template) | resource |
| [sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_snmp_feature_template) | resource |
| [sdwan_cisco_system_feature_template.cisco_system_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_system_feature_template) | resource |
| [sdwan_cisco_thousandeyes_feature_template.cisco_thousandeyes_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_thousandeyes_feature_template) | resource |
| [sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_vpn_feature_template) | resource |
| [sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_vpn_interface_feature_template) | resource |
| [sdwan_cisco_vpn_interface_gre_feature_template.cisco_vpn_interface_gre_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_vpn_interface_gre_feature_template) | resource |
| [sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cisco_vpn_interface_ipsec_feature_template) | resource |
| [sdwan_class_map_policy_object.class_map_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/class_map_policy_object) | resource |
| [sdwan_cli_config_feature.cli_config_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cli_config_feature) | resource |
| [sdwan_cli_feature_profile.cli_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cli_feature_profile) | resource |
| [sdwan_cli_template_feature_template.cli_template_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/cli_template_feature_template) | resource |
| [sdwan_color_list_policy_object.color_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/color_list_policy_object) | resource |
| [sdwan_configuration_group.configuration_group](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/configuration_group) | resource |
| [sdwan_custom_control_topology_policy_definition.custom_control_topology_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/custom_control_topology_policy_definition) | resource |
| [sdwan_data_fqdn_prefix_list_policy_object.fqdn_prefix_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/data_fqdn_prefix_list_policy_object) | resource |
| [sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/data_ipv4_prefix_list_policy_object) | resource |
| [sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/data_ipv6_prefix_list_policy_object) | resource |
| [sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/expanded_community_list_policy_object) | resource |
| [sdwan_extended_community_list_policy_object.extended_community_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/extended_community_list_policy_object) | resource |
| [sdwan_feature_device_template.feature_device_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/feature_device_template) | resource |
| [sdwan_hub_and_spoke_topology_policy_definition.hub_and_spoke_topology_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/hub_and_spoke_topology_policy_definition) | resource |
| [sdwan_intrusion_prevention_policy_definition.intrusion_prevention_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/intrusion_prevention_policy_definition) | resource |
| [sdwan_ipv4_acl_policy_definition.ipv4_acl_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv4_acl_policy_definition) | resource |
| [sdwan_ipv4_device_acl_policy_definition.ipv4_device_acl_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv4_device_acl_policy_definition) | resource |
| [sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv4_prefix_list_policy_object) | resource |
| [sdwan_ipv6_acl_policy_definition.ipv6_acl_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv6_acl_policy_definition) | resource |
| [sdwan_ipv6_device_acl_policy_definition.ipv6_device_acl_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv6_device_acl_policy_definition) | resource |
| [sdwan_ipv6_prefix_list_policy_object.ipv6_prefix_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/ipv6_prefix_list_policy_object) | resource |
| [sdwan_local_application_list_policy_object.local_application_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/local_application_list_policy_object) | resource |
| [sdwan_localized_policy.localized_policy](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/localized_policy) | resource |
| [sdwan_mesh_topology_policy_definition.mesh_topology_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/mesh_topology_policy_definition) | resource |
| [sdwan_mirror_policy_object.mirror_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/mirror_policy_object) | resource |
| [sdwan_other_feature_profile.other_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/other_feature_profile) | resource |
| [sdwan_other_thousandeyes_feature.other_thousandeyes_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/other_thousandeyes_feature) | resource |
| [sdwan_other_ucse_feature.other_ucse_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/other_ucse_feature) | resource |
| [sdwan_policer_policy_object.policer_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policer_policy_object) | resource |
| [sdwan_policy_object_app_probe_class.policy_object_app_probe_class](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_app_probe_class) | resource |
| [sdwan_policy_object_application_list.policy_object_application_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_application_list) | resource |
| [sdwan_policy_object_as_path_list.policy_object_as_path_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_as_path_list) | resource |
| [sdwan_policy_object_class_map.policy_object_class_map](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_class_map) | resource |
| [sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_data_ipv4_prefix_list) | resource |
| [sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_data_ipv6_prefix_list) | resource |
| [sdwan_policy_object_expanded_community_list.policy_object_expanded_community_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_expanded_community_list) | resource |
| [sdwan_policy_object_extended_community_list.policy_object_extended_community_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_extended_community_list) | resource |
| [sdwan_policy_object_feature_profile.policy_object_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_feature_profile) | resource |
| [sdwan_policy_object_ipv4_prefix_list.policy_object_ipv4_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_ipv4_prefix_list) | resource |
| [sdwan_policy_object_ipv6_prefix_list.policy_object_ipv6_prefix_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_ipv6_prefix_list) | resource |
| [sdwan_policy_object_mirror.policy_object_mirror](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_mirror) | resource |
| [sdwan_policy_object_policer.policy_object_policer](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_policer) | resource |
| [sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_preferred_color_group) | resource |
| [sdwan_policy_object_sla_class_list.policy_object_sla_class_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_sla_class_list) | resource |
| [sdwan_policy_object_standard_community_list.policy_object_standard_community_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_standard_community_list) | resource |
| [sdwan_policy_object_tloc_list.policy_object_tloc_list](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/policy_object_tloc_list) | resource |
| [sdwan_preferred_color_group_policy_object.preferred_color_group_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/preferred_color_group_policy_object) | resource |
| [sdwan_qos_map_policy_definition.qos_map_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/qos_map_policy_definition) | resource |
| [sdwan_region_list_policy_object.region_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/region_list_policy_object) | resource |
| [sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/rewrite_rule_policy_definition) | resource |
| [sdwan_route_policy_definition.route_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/route_policy_definition) | resource |
| [sdwan_security_app_hosting_feature_template.security_app_hosting_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/security_app_hosting_feature_template) | resource |
| [sdwan_security_policy.security_policy](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/security_policy) | resource |
| [sdwan_service_dhcp_server_feature.service_dhcp_server_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_dhcp_server_feature) | resource |
| [sdwan_service_feature_profile.service_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_feature_profile) | resource |
| [sdwan_service_ipv4_acl_feature.service_ipv4_acl_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_ipv4_acl_feature) | resource |
| [sdwan_service_lan_vpn_feature.service_lan_vpn_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_lan_vpn_feature) | resource |
| [sdwan_service_lan_vpn_feature_associate_routing_bgp_feature.service_lan_vpn_feature_associate_routing_bgp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_lan_vpn_feature_associate_routing_bgp_feature) | resource |
| [sdwan_service_object_tracker_feature.service_object_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_object_tracker_feature) | resource |
| [sdwan_service_object_tracker_group_feature.service_object_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_object_tracker_group_feature) | resource |
| [sdwan_service_route_policy_feature.service_route_policy_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_route_policy_feature) | resource |
| [sdwan_service_routing_bgp_feature.service_routing_bgp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_routing_bgp_feature) | resource |
| [sdwan_service_tracker_feature.service_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_tracker_feature) | resource |
| [sdwan_service_tracker_group_feature.service_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/service_tracker_group_feature) | resource |
| [sdwan_site_list_policy_object.site_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/site_list_policy_object) | resource |
| [sdwan_sla_class_policy_object.sla_class_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/sla_class_policy_object) | resource |
| [sdwan_standard_community_list_policy_object.standard_community_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/standard_community_list_policy_object) | resource |
| [sdwan_switchport_feature_template.switchport_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/switchport_feature_template) | resource |
| [sdwan_system_aaa_feature.system_aaa_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_aaa_feature) | resource |
| [sdwan_system_banner_feature.system_banner_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_banner_feature) | resource |
| [sdwan_system_basic_feature.system_basic_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_basic_feature) | resource |
| [sdwan_system_bfd_feature.system_bfd_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_bfd_feature) | resource |
| [sdwan_system_feature_profile.system_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_feature_profile) | resource |
| [sdwan_system_flexible_port_speed_feature.system_flexible_port_speed_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_flexible_port_speed_feature) | resource |
| [sdwan_system_global_feature.system_global_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_global_feature) | resource |
| [sdwan_system_ipv4_device_access_feature.system_ipv4_device_access_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_ipv4_device_access_feature) | resource |
| [sdwan_system_ipv6_device_access_feature.system_ipv6_device_access_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_ipv6_device_access_feature) | resource |
| [sdwan_system_logging_feature.system_logging_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_logging_feature) | resource |
| [sdwan_system_mrf_feature.system_mrf_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_mrf_feature) | resource |
| [sdwan_system_ntp_feature.system_ntp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_ntp_feature) | resource |
| [sdwan_system_omp_feature.system_omp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_omp_feature) | resource |
| [sdwan_system_performance_monitoring_feature.system_performance_monitoring_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_performance_monitoring_feature) | resource |
| [sdwan_system_security_feature.system_security_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_security_feature) | resource |
| [sdwan_system_snmp_feature.system_snmp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/system_snmp_feature) | resource |
| [sdwan_tag.tag](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/tag) | resource |
| [sdwan_tloc_list_policy_object.tloc_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/tloc_list_policy_object) | resource |
| [sdwan_traffic_data_policy_definition.traffic_data_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/traffic_data_policy_definition) | resource |
| [sdwan_transport_cellular_profile_feature.transport_cellular_profile_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_cellular_profile_feature) | resource |
| [sdwan_transport_feature_profile.transport_feature_profile](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_feature_profile) | resource |
| [sdwan_transport_gps_feature.transport_gps_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_gps_feature) | resource |
| [sdwan_transport_ipv4_acl_feature.transport_ipv4_acl_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_ipv4_acl_feature) | resource |
| [sdwan_transport_ipv6_tracker_feature.transport_ipv6_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_ipv6_tracker_feature) | resource |
| [sdwan_transport_ipv6_tracker_group_feature.transport_ipv6_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_ipv6_tracker_group_feature) | resource |
| [sdwan_transport_management_vpn_feature.transport_management_vpn_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_management_vpn_feature) | resource |
| [sdwan_transport_management_vpn_interface_ethernet_feature.transport_management_vpn_interface_ethernet_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_management_vpn_interface_ethernet_feature) | resource |
| [sdwan_transport_route_policy_feature.transport_route_policy_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_route_policy_feature) | resource |
| [sdwan_transport_routing_bgp_feature.transport_routing_bgp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_routing_bgp_feature) | resource |
| [sdwan_transport_tracker_feature.transport_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_tracker_feature) | resource |
| [sdwan_transport_tracker_group_feature.transport_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_tracker_group_feature) | resource |
| [sdwan_transport_wan_vpn_feature.transport_wan_vpn_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_feature) | resource |
| [sdwan_transport_wan_vpn_feature_associate_routing_bgp_feature.transport_wan_vpn_feature_associate_routing_bgp_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_feature_associate_routing_bgp_feature) | resource |
| [sdwan_transport_wan_vpn_interface_ethernet_feature.transport_wan_vpn_interface_ethernet_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_interface_ethernet_feature) | resource |
| [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_feature) | resource |
| [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_interface_ethernet_feature_associate_ipv6_tracker_group_feature) | resource |
| [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_interface_ethernet_feature_associate_tracker_feature) | resource |
| [sdwan_transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature.transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/transport_wan_vpn_interface_ethernet_feature_associate_tracker_group_feature) | resource |
| [sdwan_vpn_interface_cellular_feature_template.vpn_interface_cellular_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/vpn_interface_cellular_feature_template) | resource |
| [sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/vpn_interface_svi_feature_template) | resource |
| [sdwan_vpn_list_policy_object.vpn_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/vpn_list_policy_object) | resource |
| [sdwan_vpn_membership_policy_definition.vpn_membership_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/vpn_membership_policy_definition) | resource |
| [sdwan_zone_based_firewall_policy_definition.zone_based_firewall_policy_definition](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/zone_based_firewall_policy_definition) | resource |
| [sdwan_zone_list_policy_object.zone_list_policy_object](https://registry.terraform.io/providers/CiscoDevNet/sdwan/latest/docs/resources/zone_list_policy_object) | resource |
| [utils_yaml_merge.defaults](https://registry.terraform.io/providers/netascode/utils/latest/docs/data-sources/yaml_merge) | data source |
| [utils_yaml_merge.model](https://registry.terraform.io/providers/netascode/utils/latest/docs/data-sources/yaml_merge) | data source |

## Modules

No modules.
<!-- END_TF_DOCS -->