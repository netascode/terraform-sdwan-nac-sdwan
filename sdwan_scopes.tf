locals {
  scope_feature_profile_ids = merge(
    { for k, v in sdwan_embedded_security_feature_profile.embedded_security_feature_profile : k => v.id },
    { for k, v in sdwan_application_priority_feature_profile.application_priority_feature_profile : k => v.id },
    { for k, v in sdwan_cli_feature_profile.cli_feature_profile : k => v.id },
    { for k, v in sdwan_other_feature_profile.other_feature_profile : k => v.id },
    { for k, v in sdwan_service_feature_profile.service_feature_profile : k => v.id },
    { for k, v in sdwan_system_feature_profile.system_feature_profile : k => v.id },
    { for k, v in sdwan_sse_feature_profile.sse_feature_profile : k => v.id },
    { for k, v in sdwan_topology_feature_profile.topology_feature_profile : k => v.id },
    { for k, v in sdwan_transport_feature_profile.transport_feature_profile : k => v.id },
    length(sdwan_policy_object_feature_profile.policy_object_feature_profile) == 0 ? {} : {
      (sdwan_policy_object_feature_profile.policy_object_feature_profile[0].name) = sdwan_policy_object_feature_profile.policy_object_feature_profile[0].id
    },
  )

  scope_feature_template_ids = merge(
    { for k, v in sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template : k => v.id },
    { for k, v in sdwan_cedge_global_feature_template.cedge_global_feature_template : k => v.id },
    { for k, v in sdwan_cedge_igmp_feature_template.cedge_igmp_feature_template : k => v.id },
    { for k, v in sdwan_cisco_banner_feature_template.cisco_banner_feature_template : k => v.id },
    { for k, v in sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template : k => v.id },
    { for k, v in sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template : k => v.id },
    { for k, v in sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template : k => v.id },
    { for k, v in sdwan_cisco_logging_feature_template.cisco_logging_feature_template : k => v.id },
    { for k, v in sdwan_cedge_multicast_feature_template.cedge_multicast_feature_template : k => v.id },
    { for k, v in sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template : k => v.id },
    { for k, v in sdwan_cisco_omp_feature_template.cisco_omp_feature_template : k => v.id },
    { for k, v in sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template : k => v.id },
    { for k, v in sdwan_cedge_pim_feature_template.cedge_pim_feature_template : k => v.id },
    { for k, v in sdwan_cisco_secure_internet_gateway_feature_template.cisco_secure_internet_gateway_feature_template : k => v.id },
    { for k, v in sdwan_cisco_security_feature_template.cisco_security_feature_template : k => v.id },
    { for k, v in sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template : k => v.id },
    { for k, v in sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template : k => v.id },
    { for k, v in sdwan_cisco_system_feature_template.cisco_system_feature_template : k => v.id },
    { for k, v in sdwan_cisco_thousandeyes_feature_template.cisco_thousandeyes_feature_template : k => v.id },
    { for k, v in sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template : k => v.id },
    { for k, v in sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template : k => v.id },
    { for k, v in sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template : k => v.id },
    { for k, v in sdwan_cli_template_feature_template.cli_template_feature_template : k => v.id },
    { for k, v in sdwan_switchport_feature_template.switchport_feature_template : k => v.id },
    { for k, v in sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template : k => v.id },
    { for k, v in sdwan_security_app_hosting_feature_template.security_app_hosting_feature_template : k => v.id },
    { for k, v in sdwan_cellular_controller_feature_template.cellular_controller_feature_template : k => v.id },
    { for k, v in sdwan_cellular_cedge_profile_feature_template.cellular_cedge_profile_feature_template : k => v.id },
    { for k, v in sdwan_cisco_vpn_interface_gre_feature_template.cisco_vpn_interface_gre_feature_template : k => v.id },
    { for k, v in sdwan_vpn_interface_cellular_feature_template.vpn_interface_cellular_feature_template : k => v.id },
  )

  # Keyed by node name: node names are globally unique in this module, since
  # sdwan_network_hierarchy.tf:83 keys containers by bare name and :95 keys
  # sites by bare name, so duplicates already fail at plan time.
  # Merging all seven levels is acyclic and safe here because only sdwan_scope
  # reads this map and sdwan_scope is not one of the merged resources
  scope_network_hierarchy_node_ids = merge(
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l0 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l0 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l1 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l1 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l2 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l2 : v.name => v.id },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_site : v.name => v.id },
    # "Global" is the built-in hierarchy root created by SD-WAN Manager itself, so
    # it is never one of the nodes this module creates. Its UUID is generated per
    # controller and cannot be hardcoded, so it is read back by name on demand.
    length(data.sdwan_network_hierarchy_node.scope_global) == 0 ? {} : {
      "Global" = data.sdwan_network_hierarchy_node.scope_global[0].id
    },
  )
}

# Only read the built-in root when a scope actually references it, so deployments
# that never scope to "Global" do not pay for an extra API call on every plan.
data "sdwan_network_hierarchy_node" "scope_global" {
  count = anytrue([
    for s in try(local.scopes, []) : contains(try(s.network_hierarchy_nodes, []), "Global")
  ]) ? 1 : 0
  name = "Global"
}

resource "sdwan_scope" "scope" {
  for_each    = { for s in try(local.scopes, []) : s.name => s }
  name        = each.value.name
  description = try(each.value.description, "")
  users       = try(each.value.users, null)
  objects = concat(
    try(each.value.configuration_groups, null) == null ? [] : [{
      object_type = "config-group"
      object_ids  = tolist([for n in each.value.configuration_groups : sdwan_configuration_group.configuration_group[n].id])
    }],
    try(each.value.feature_profiles, null) == null ? [] : [{
      object_type = "feature-profile"
      object_ids  = tolist([for n in each.value.feature_profiles : local.scope_feature_profile_ids[n]])
    }],
    try(each.value.edge_device_templates, null) == null ? [] : [{
      object_type = "device-template"
      object_ids  = tolist([for n in each.value.edge_device_templates : sdwan_feature_device_template.feature_device_template[n].id])
    }],
    try(each.value.edge_feature_templates, null) == null ? [] : [{
      object_type = "feature-template"
      object_ids  = tolist([for n in each.value.edge_feature_templates : local.scope_feature_template_ids[n]])
    }],
    try(each.value.localized_policies, null) == null ? [] : [{
      object_type = "localized-policy"
      object_ids  = tolist([for n in each.value.localized_policies : sdwan_localized_policy.localized_policy[n].id])
    }],
    try(each.value.security_policies, null) == null ? [] : [{
      object_type = "security-policy"
      object_ids  = tolist([for n in each.value.security_policies : sdwan_security_policy.security_policy[n].id])
    }],
    try(each.value.network_hierarchy_nodes, null) == null ? [] : [{
      object_type = "network-hierarchy-node"
      object_ids  = tolist([for n in each.value.network_hierarchy_nodes : local.scope_network_hierarchy_node_ids[n]])
    }],
  )
}
