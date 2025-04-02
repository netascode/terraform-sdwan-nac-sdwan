resource "sdwan_feature_device_template" "feature_device_template" {
  for_each                = { for t in try(local.edge_device_templates, {}) : t.name => t }
  name                    = each.value.name
  description             = each.value.description
  device_type             = try(local.device_type_map[each.value.device_model], "vedge-${each.value.device_model}")
  device_role             = "sdwan-edge"
  policy_id               = try(each.value.localized_policy, null) == null ? null : sdwan_localized_policy.localized_policy[each.value.localized_policy].id
  policy_version          = try(each.value.localized_policy, null) == null ? null : sdwan_localized_policy.localized_policy[each.value.localized_policy].version
  security_policy_id      = try(each.value.security_policy.name, null) == null ? null : sdwan_security_policy.security_policy[each.value.security_policy.name].id
  security_policy_version = try(each.value.security_policy.name, null) == null ? null : sdwan_security_policy.security_policy[each.value.security_policy.name].version
  general_templates = flatten([
    try(each.value.security_policy.container_profile, null) == null ? [] : [{
      id      = sdwan_security_app_hosting_feature_template.security_app_hosting_feature_template[each.value.security_policy.container_profile].id
      version = sdwan_security_app_hosting_feature_template.security_app_hosting_feature_template[each.value.security_policy.container_profile].version
      type    = "virtual-application-utd"
    }],
    try(each.value.system_template, null) == null ? [] : [{
      id      = sdwan_cisco_system_feature_template.cisco_system_feature_template[each.value.system_template].id
      version = sdwan_cisco_system_feature_template.cisco_system_feature_template[each.value.system_template].version
      type    = "cisco_system"
      sub_templates = !(can(each.value.logging_template) ||
        can(each.value.ntp_template)) ? null : flatten([
          try(each.value.logging_template, null) == null ? [] : [{
            id      = sdwan_cisco_logging_feature_template.cisco_logging_feature_template[each.value.logging_template].id
            version = sdwan_cisco_logging_feature_template.cisco_logging_feature_template[each.value.logging_template].version
            type    = "cisco_logging"
          }],
          try(each.value.ntp_template, null) == null ? [] : [{
            id      = sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template[each.value.ntp_template].id
            version = sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template[each.value.ntp_template].version
            type    = "cisco_ntp"
          }]
      ])
    }],
    try(each.value.aaa_template, null) == null ? [] : [{
      id      = sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template[each.value.aaa_template].id
      version = sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template[each.value.aaa_template].version
      type    = "cedge_aaa"
    }],
    try(each.value.bfd_template, null) == null ? [] : [{
      id      = sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template[each.value.bfd_template].id
      version = sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template[each.value.bfd_template].version
      type    = "cisco_bfd"
    }],
    try(each.value.omp_template, null) == null ? [] : [{
      id      = sdwan_cisco_omp_feature_template.cisco_omp_feature_template[each.value.omp_template].id
      version = sdwan_cisco_omp_feature_template.cisco_omp_feature_template[each.value.omp_template].version
      type    = "cisco_omp"
    }],
    try(each.value.security_template, null) == null ? [] : [{
      id      = sdwan_cisco_security_feature_template.cisco_security_feature_template[each.value.security_template].id
      version = sdwan_cisco_security_feature_template.cisco_security_feature_template[each.value.security_template].version
      type    = "cisco_security"
    }],
    try(each.value.banner_template, null) == null ? [] : [{
      id      = sdwan_cisco_banner_feature_template.cisco_banner_feature_template[each.value.banner_template].id
      version = sdwan_cisco_banner_feature_template.cisco_banner_feature_template[each.value.banner_template].version
      type    = "cisco_banner"
    }],
    try(each.value.snmp_template, null) == null ? [] : [{
      id      = sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template[each.value.snmp_template].id
      version = sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template[each.value.snmp_template].version
      type    = "cisco_snmp"
    }],
    try(each.value.global_settings_template, null) == null ? [] : [{
      id      = sdwan_cedge_global_feature_template.cedge_global_feature_template[each.value.global_settings_template].id
      version = sdwan_cedge_global_feature_template.cedge_global_feature_template[each.value.global_settings_template].version
      type    = "cedge_global"
    }],
    try(each.value.cli_template, null) == null ? [] : [{
      id      = sdwan_cli_template_feature_template.cli_template_feature_template[each.value.cli_template].id
      version = sdwan_cli_template_feature_template.cli_template_feature_template[each.value.cli_template].version
      type    = "cli-template"
    }],
    try(each.value.vpn_0_template.sig_credentials_template, null) == null ? [] : [{
      id      = sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template[each.value.vpn_0_template.sig_credentials_template].id
      version = sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template[each.value.vpn_0_template.sig_credentials_template].version
      type    = "cisco_sig_credentials"
    }],
    try(each.value.switchport_templates, null) == null ? [] : [for spt in try(each.value.switchport_templates, []) : {
      id      = sdwan_switchport_feature_template.switchport_feature_template[spt.name].id
      version = sdwan_switchport_feature_template.switchport_feature_template[spt.name].version
      type    = "switchport"
    }],
    try(each.value.thousandeyes_template, null) == null ? [] : [{
      id      = sdwan_cisco_thousandeyes_feature_template.cisco_thousandeyes_feature_template[each.value.thousandeyes_template].id
      version = sdwan_cisco_thousandeyes_feature_template.cisco_thousandeyes_feature_template[each.value.thousandeyes_template].version
      type    = "cisco_thousandeyes"
    }],
    try(each.value.vpn_0_template, null) == null ? [] : [{
      id      = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[each.value.vpn_0_template.name].id
      version = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[each.value.vpn_0_template.name].version
      type    = "cisco_vpn"
      sub_templates = !(can(each.value.vpn_0_template.ospf_template) ||
        can(each.value.vpn_0_template.bgp_template) ||
        can(each.value.vpn_0_template.ethernet_interface_templates) ||
        can(each.value.vpn_0_template.ipsec_interface_templates) ||
        can(each.value.vpn_0_template.svi_interface_templates) ||
        can(each.value.vpn_0_template.secure_internet_gateway_template)) ? null : flatten([
          try(each.value.vpn_0_template.ospf_template, null) == null ? [] : [{
            id      = sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[each.value.vpn_0_template.ospf_template].id
            version = sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[each.value.vpn_0_template.ospf_template].version
            type    = "cisco_ospf"
          }],
          try(each.value.vpn_0_template.bgp_template, null) == null ? [] : [{
            id      = sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[each.value.vpn_0_template.bgp_template].id
            version = sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[each.value.vpn_0_template.bgp_template].version
            type    = "cisco_bgp"
          }],
          try(each.value.vpn_0_template.ethernet_interface_templates, null) == null ? [] : [for eit in try(each.value.vpn_0_template.ethernet_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].id
            version = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].version
            type    = "cisco_vpn_interface"
          }],
          try(each.value.vpn_0_template.ipsec_interface_templates, null) == null ? [] : [for iit in try(each.value.vpn_0_template.ipsec_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template[iit.name].id
            version = sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template[iit.name].version
            type    = "cisco_vpn_interface_ipsec"
            sub_templates = !can(iit.dhcp_server_template) ? null : flatten([
              try(iit.dhcp_server_template, null) == null ? [] : [{
                id      = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[iit.dhcp_server_template].id
                version = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[iit.dhcp_server_template].version
                type    = "cisco_dhcp_server"
              }],
            ])
          }],
          try(each.value.vpn_0_template.svi_interface_templates, null) == null ? [] : [for sit in try(each.value.vpn_0_template.svi_interface_templates, []) : {
            id      = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].id
            version = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].version
            type    = "vpn-interface-svi"
          }],
          try(each.value.vpn_0_template.secure_internet_gateway_template, null) == null ? [] : [{
            id      = sdwan_cisco_secure_internet_gateway_feature_template.cisco_secure_internet_gateway_feature_template[each.value.vpn_0_template.secure_internet_gateway_template].id
            version = sdwan_cisco_secure_internet_gateway_feature_template.cisco_secure_internet_gateway_feature_template[each.value.vpn_0_template.secure_internet_gateway_template].version
            type    = "cisco_secure_internet_gateway"
          }],
          try(each.value.vpn_0_template.gre_interface_templates, null) == null ? [] : [for sit in try(each.value.vpn_0_template.gre_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_gre_feature_template.cisco_vpn_interface_gre_feature_template[sit.name].id
            version = sdwan_cisco_vpn_interface_gre_feature_template.cisco_vpn_interface_gre_feature_template[sit.name].version
            type    = "cisco_vpn_interface_gre"
          }],
          try(each.value.vpn_0_template.cellular_interface_templates, null) == null ? [] : [for sit in try(each.value.vpn_0_template.cellular_interface_templates, []) : {
            id      = sdwan_vpn_interface_cellular_feature_template.vpn_interface_cellular_feature_template[sit.name].id
            version = sdwan_vpn_interface_cellular_feature_template.vpn_interface_cellular_feature_template[sit.name].version
            type    = "vpn-cedge-interface-cellular"
          }],
      ])
    }],
    try(each.value.vpn_512_template, null) == null ? [] : [{
      id      = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[each.value.vpn_512_template.name].id
      version = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[each.value.vpn_512_template.name].version
      type    = "cisco_vpn"
      sub_templates = !(can(each.value.vpn_512_template.ethernet_interface_templates) ||
        can(each.value.vpn_512_template.svi_interface_templates)) ? null : flatten([
          try(each.value.vpn_512_template.ethernet_interface_templates, null) == null ? [] : [for eit in try(each.value.vpn_512_template.ethernet_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].id
            version = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].version
            type    = "cisco_vpn_interface"
          }],
          try(each.value.vpn_512_template.svi_interface_templates, null) == null ? [] : [for sit in try(each.value.vpn_512_template.svi_interface_templates, []) : {
            id      = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].id
            version = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].version
            type    = "vpn-interface-svi"
          }],
      ])
    }],
    try(each.value.vpn_service_templates, null) == null ? try([for ss in try(each.value.vpn_service_templates, []) : null], []) : [for st in try(each.value.vpn_service_templates, []) : {
      id      = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[st.name].id
      version = sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[st.name].version
      type    = "cisco_vpn"
      sub_templates = !(can(st.ospf_template) ||
        can(st.bgp_template) ||
        can(st.ethernet_interface_templates) ||
        can(st.ipsec_interface_templates) ||
        can(st.svi_interface_templates)) ? null : flatten([
          try(st.ospf_template, null) == null ? [] : [{
            id      = sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[st.ospf_template].id
            version = sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[st.ospf_template].version
            type    = "cisco_ospf"
          }],
          try(st.bgp_template, null) == null ? [] : [{
            id      = sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[st.bgp_template].id
            version = sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[st.bgp_template].version
            type    = "cisco_bgp"
          }],
          try(st.ethernet_interface_templates, null) == null ? [] : [for eit in try(st.ethernet_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].id
            version = sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[eit.name].version
            type    = "cisco_vpn_interface"
            sub_templates = try(eit.dhcp_server_template, null) == null ? null : [{
              id      = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[eit.dhcp_server_template].id
              version = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[eit.dhcp_server_template].version
              type    = "cisco_dhcp_server"
            }]
          }],
          try(st.ipsec_interface_templates, null) == null ? [] : [for iit in try(st.ipsec_interface_templates, []) : {
            id      = sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template[iit.name].id
            version = sdwan_cisco_vpn_interface_ipsec_feature_template.cisco_vpn_interface_ipsec_feature_template[iit.name].version
            type    = "cisco_vpn_interface_ipsec"
            sub_templates = try(iit.dhcp_server_template, null) == null ? null : [{
              id      = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[iit.dhcp_server_template].id
              version = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[iit.dhcp_server_template].version
              type    = "cisco_dhcp_server"
            }]
          }],
          try(st.svi_interface_templates, null) == null ? [] : [for sit in try(st.svi_interface_templates, []) : {
            id      = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].id
            version = sdwan_vpn_interface_svi_feature_template.vpn_interface_svi_feature_template[sit.name].version
            type    = "vpn-interface-svi"
            sub_templates = try(sit.dhcp_server_template, null) == null ? null : [{
              id      = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[sit.dhcp_server_template].id
              version = sdwan_cisco_dhcp_server_feature_template.cisco_dhcp_server_feature_template[sit.dhcp_server_template].version
              type    = "cisco_dhcp_server"
            }],
          }],
      ])
    }],
    try(each.value.cellular_controller_templates, null) == null ? [] : [for st in try(each.value.cellular_controller_templates, []) : {
      id      = sdwan_cellular_controller_feature_template.cellular_controller_feature_template[st.name].id
      version = sdwan_cellular_controller_feature_template.cellular_controller_feature_template[st.name].version
      type    = "cellular-cedge-controller"
      sub_templates = !(can(st.cellular_profile_templates)) ? null : flatten([
        try(st.cellular_profile_templates, null) == null ? [] : [for eit in try(st.cellular_profile_templates, []) : {
          id      = sdwan_cellular_cedge_profile_feature_template.cellular_cedge_profile_feature_template[eit.name].id
          version = sdwan_cellular_cedge_profile_feature_template.cellular_cedge_profile_feature_template[eit.name].version
          type    = "cellular-cedge-profile"
        }],
      ])
    }]
  ])
  lifecycle {
    create_before_destroy = true
  }
}

locals {
  routers = flatten([
    for site in try(local.sites, []) : [
      for router in try(site.routers, []) : {
        chassis_id                 = router.chassis_id
        configuration_group        = try(router.configuration_group, null)
        configuration_group_deploy = try(router.configuration_group_deploy, null)
        tags                       = try(router.tags, [])
        device_template            = try(router.device_template, null)
        device_variables           = try(router.device_variables, null)
        model                      = try(router.model, null)
      }
    ]
  ])
}

resource "sdwan_attach_feature_device_template" "attach_feature_device_template" {
  for_each = { for r in local.routers : r.chassis_id => r if r.device_template != null }
  id       = sdwan_feature_device_template.feature_device_template[each.value.device_template].id
  version  = sdwan_feature_device_template.feature_device_template[each.value.device_template].version
  devices = [
    {
      id        = each.value.chassis_id
      variables = each.value.device_variables
    }
  ]
}
