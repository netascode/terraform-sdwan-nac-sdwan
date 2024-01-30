resource "sdwan_feature_device_template" "feature_device_template" {
  for_each       = { for t in try(local.cedge_device_templates.device_template, {}) : t.name => t }
  name           = each.value.name
  description    = each.value.description
  device_type    = try(local.device_type_map[each.value.parameters.device_model], "vedge-${each.value.parameters.device_model}")
  policy_id      = try(sdwan_localized_policy.localized_policy[each.value.parameters.localized_policy].id, null)
  policy_version = try(sdwan_localized_policy.localized_policy[each.value.parameters.localized_policy].version, null)
  general_templates = try(length(each.value.parameters.feature_templates) == 0, true) ? null : [for ft in each.value.parameters.feature_templates : {
    id = (
      ft.templateType == "cedge_aaa" ? sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template[ft.templateName].id :
      ft.templateType == "cedge_global" ? sdwan_cedge_global_feature_template.cedge_global_feature_template[ft.templateName].id :
      ft.templateType == "cisco_banner" ? sdwan_cisco_banner_feature_template.cisco_banner_feature_template[ft.templateName].id :
      ft.templateType == "cisco_bfd" ? sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template[ft.templateName].id :
      ft.templateType == "cisco_omp" ? sdwan_cisco_omp_feature_template.cisco_omp_feature_template[ft.templateName].id :
      ft.templateType == "cisco_security" ? sdwan_cisco_security_feature_template.cisco_security_feature_template[ft.templateName].id :
      ft.templateType == "cisco_sig_credentials" ? sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template[ft.templateName].id :
      ft.templateType == "cisco_snmp" ? sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template[ft.templateName].id :
      ft.templateType == "cisco_system" ? sdwan_cisco_system_feature_template.cisco_system_feature_template[ft.templateName].id :
      ft.templateType == "cisco_vpn" ? sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[ft.templateName].id :
      ft.templateType == "cli-template" ? sdwan_cli_template_feature_template.cli_template_feature_template[ft.templateName].id : null
    )
    version = (
      ft.templateType == "cedge_aaa" ? sdwan_cedge_aaa_feature_template.cedge_aaa_feature_template[ft.templateName].version :
      ft.templateType == "cedge_global" ? sdwan_cedge_global_feature_template.cedge_global_feature_template[ft.templateName].version :
      ft.templateType == "cisco_banner" ? sdwan_cisco_banner_feature_template.cisco_banner_feature_template[ft.templateName].version :
      ft.templateType == "cisco_bfd" ? sdwan_cisco_bfd_feature_template.cisco_bfd_feature_template[ft.templateName].version :
      ft.templateType == "cisco_omp" ? sdwan_cisco_omp_feature_template.cisco_omp_feature_template[ft.templateName].version :
      ft.templateType == "cisco_security" ? sdwan_cisco_security_feature_template.cisco_security_feature_template[ft.templateName].version :
      ft.templateType == "cisco_sig_credentials" ? sdwan_cisco_sig_credentials_feature_template.cisco_sig_credentials_feature_template[ft.templateName].version :
      ft.templateType == "cisco_snmp" ? sdwan_cisco_snmp_feature_template.cisco_snmp_feature_template[ft.templateName].version :
      ft.templateType == "cisco_system" ? sdwan_cisco_system_feature_template.cisco_system_feature_template[ft.templateName].version :
      ft.templateType == "cisco_vpn" ? sdwan_cisco_vpn_feature_template.cisco_vpn_feature_template[ft.templateName].version :
      ft.templateType == "cli-template" ? sdwan_cli_template_feature_template.cli_template_feature_template[ft.templateName].version : null
    )
    type = ft.templateType
    #sub_templates = null
    sub_templates = try(length(ft.subTemplates) == 0, true) ? null : [for st in ft.subTemplates : {
      id = (
        st.templateType == "cisco_bgp" ? sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[st.templateName].id :
        st.templateType == "cisco_ospf" ? sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[st.templateName].id :
        st.templateType == "cisco_ntp" ? sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template[st.templateName].id :
        st.templateType == "cisco_logging" ? sdwan_cisco_logging_feature_template.cisco_logging_feature_template[st.templateName].id :
        st.templateType == "cisco_vpn_interface" ? sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[st.templateName].id : null
      )
      version = (
        st.templateType == "cisco_bgp" ? sdwan_cisco_bgp_feature_template.cisco_bgp_feature_template[st.templateName].version :
        st.templateType == "cisco_ospf" ? sdwan_cisco_ospf_feature_template.cisco_ospf_feature_template[st.templateName].version :
        st.templateType == "cisco_ntp" ? sdwan_cisco_ntp_feature_template.cisco_ntp_feature_template[st.templateName].version :
        st.templateType == "cisco_logging" ? sdwan_cisco_logging_feature_template.cisco_logging_feature_template[st.templateName].version :
        st.templateType == "cisco_vpn_interface" ? sdwan_cisco_vpn_interface_feature_template.cisco_vpn_interface_feature_template[st.templateName].version : null
      )
      type = st.templateType
    }]
  }]
}


locals {
  routers = flatten([
    for site in try(local.sites, []) : [
      for router in try(site.routers, []) : {
        chassis_id       = router.chassis_id
        model            = router.model
        device_template  = router.device_template
        device_variables = router.device_variables
      }
    ]
  ])
}

resource "sdwan_attach_feature_device_template" "attach_feature_device_template" {
  for_each = { for r in local.routers : r.chassis_id => r }
  id       = sdwan_feature_device_template.feature_device_template[each.value.device_template].id
  version  = sdwan_feature_device_template.feature_device_template[each.value.device_template].version
  devices = [
    {
      id        = each.value.chassis_id
      variables = each.value.device_variables
    }
  ]
}
