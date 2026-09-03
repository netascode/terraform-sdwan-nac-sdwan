resource "sdwan_other_thousandeyes_feature" "other_thousandeyes_feature" {
  for_each = {
    for other in try(local.feature_profiles.other_profiles, {}) :
    "${other.name}-thousandeyes" => other
    if try(other.thousandeyes, null) != null
  }
  name               = try(each.value.thousandeyes.name, local.defaults.sdwan.feature_profiles.other_profiles.thousandeyes.name)
  description        = try(each.value.thousandeyes.description, "")
  feature_profile_id = sdwan_other_feature_profile.other_feature_profile[each.value.name].id
  virtual_application = [{
    account_group_token             = try(each.value.thousandeyes.account_group_token, null)
    account_group_token_variable    = try("{{${each.value.thousandeyes.account_group_token_variable}}}", null)
    agent_default_gateway           = try(each.value.thousandeyes.agent_default_gateway, null)
    agent_default_gateway_variable  = try("{{${each.value.thousandeyes.agent_default_gateway_variable}}}", null)
    hostname                        = try(each.value.thousandeyes.hostname, null)
    hostname_variable               = try("{{${each.value.thousandeyes.hostname_variable}}}", null)
    management_ip                   = try(each.value.thousandeyes.management_ip, null)
    management_ip_variable          = try("{{${each.value.thousandeyes.management_ip_variable}}}", null)
    management_subnet_mask          = try(each.value.thousandeyes.management_subnet_mask, null)
    management_subnet_mask_variable = try("{{${each.value.thousandeyes.management_subnet_mask_variable}}}", null)
    name_server_ip                  = try(each.value.thousandeyes.name_server_ip, null)
    name_server_ip_variable         = try("{{${each.value.thousandeyes.name_server_ip_variable}}}", null)
    pac_url                         = try(each.value.thousandeyes.pac_proxy_url, null)
    pac_url_variable                = try("{{${each.value.thousandeyes.pac_proxy_url_variable}}}", null)
    proxy_host                      = try(each.value.thousandeyes.static_proxy_host, null)
    proxy_host_variable             = try("{{${each.value.thousandeyes.static_proxy_host_variable}}}", null)
    proxy_port                      = try(each.value.thousandeyes.static_proxy_port, null)
    proxy_port_variable             = try("{{${each.value.thousandeyes.static_proxy_port_variable}}}", null)
    proxy_type                      = try(each.value.thousandeyes.proxy_type, null)
    vpn                             = try(each.value.thousandeyes.vpn_id, null)
    vpn_variable                    = try("{{${each.value.thousandeyes.vpn_id_variable}}}", null)
  }]
}

resource "sdwan_other_trustsec_feature" "other_trustsec_feature" {
  for_each = {
    for other in try(local.feature_profiles.other_profiles, {}) :
    "${other.name}-trustsec" => other
    if try(other.trustsec, null) != null
  }
  name                            = try(each.value.trustsec.name, local.defaults.sdwan.feature_profiles.other_profiles.trustsec.name)
  description                     = try(each.value.trustsec.description, "")
  feature_profile_id              = sdwan_other_feature_profile.other_feature_profile[each.value.name].id
  device_id                       = try(each.value.trustsec.device_id, null)
  device_id_variable              = try("{{${each.value.trustsec.device_id_variable}}}", null)
  device_password                 = try(each.value.trustsec.device_password, null)
  device_password_variable        = try("{{${each.value.trustsec.device_password_variable}}}", null)
  device_sgt                      = try(each.value.trustsec.device_sgt, null)
  device_sgt_variable             = try("{{${each.value.trustsec.device_sgt_variable}}}", null)
  enable_enforcement              = try(each.value.trustsec.enable_enforcement, null)
  enable_enforcement_variable     = try("{{${each.value.trustsec.enable_enforcement_variable}}}", null)
  enable_sxp                      = try(each.value.trustsec.enable_sxp, null)
  listener_hold_time_max          = try(each.value.trustsec.listener_hold_time_max, null)
  listener_hold_time_max_variable = try("{{${each.value.trustsec.listener_hold_time_max_variable}}}", null)
  listener_hold_time_min          = try(each.value.trustsec.listener_hold_time_min, null)
  listener_hold_time_min_variable = try("{{${each.value.trustsec.listener_hold_time_min_variable}}}", null)
  speaker_hold_time               = try(each.value.trustsec.speaker_hold_time, null)
  speaker_hold_time_variable      = try("{{${each.value.trustsec.speaker_hold_time_variable}}}", null)
  sxp_connections = try(length(each.value.trustsec.sxp_connections) == 0, true) ? null : [for c in each.value.trustsec.sxp_connections : {
    max_hold_time          = try(c.max_hold_time, null)
    max_hold_time_variable = try("{{${c.max_hold_time_variable}}}", null)
    min_hold_time          = try(c.min_hold_time, null)
    min_hold_time_variable = try("{{${c.min_hold_time_variable}}}", null)
    mode                   = try(c.mode, null)
    mode_type              = try(c.mode_type, null)
    peer_ip                = try(c.peer_ip, null)
    peer_ip_variable       = try("{{${c.peer_ip_variable}}}", null)
    preshared_key          = try(c.preshared_key, null)
    source_ip              = try(c.source_ip, null)
    source_ip_variable     = try("{{${c.source_ip_variable}}}", null)
    vpn_id                 = try(c.vpn_id, null)
    vpn_id_variable        = try("{{${c.vpn_id_variable}}}", null)
  }]
  sxp_default_password               = try(each.value.trustsec.sxp_default_password, null)
  sxp_default_password_variable      = try("{{${each.value.trustsec.sxp_default_password_variable}}}", null)
  sxp_key_chain                      = try(each.value.trustsec.sxp_key_chain, null)
  sxp_key_chain_variable             = try("{{${each.value.trustsec.sxp_key_chain_variable}}}", null)
  sxp_log_binding_changes            = try(each.value.trustsec.sxp_log_binding_changes, null)
  sxp_log_binding_changes_variable   = try("{{${each.value.trustsec.sxp_log_binding_changes_variable}}}", null)
  sxp_reconciliation_period          = try(each.value.trustsec.sxp_reconciliation_period, null)
  sxp_reconciliation_period_variable = try("{{${each.value.trustsec.sxp_reconciliation_period_variable}}}", null)
  sxp_retry_period                   = try(each.value.trustsec.sxp_retry_period, null)
  sxp_retry_period_variable          = try("{{${each.value.trustsec.sxp_retry_period_variable}}}", null)
  sxp_source_ip                      = try(each.value.trustsec.sxp_source_ip, null)
  sxp_source_ip_variable             = try("{{${each.value.trustsec.sxp_source_ip_variable}}}", null)
}

resource "sdwan_other_ucse_feature" "other_ucse_feature" {
  for_each = {
    for other in try(local.feature_profiles.other_profiles, {}) :
    "${other.name}-ucse" => other
    if try(other.ucse, null) != null
  }
  name                             = try(each.value.ucse.name, local.defaults.sdwan.feature_profiles.other_profiles.ucse.name)
  description                      = try(each.value.ucse.description, "")
  feature_profile_id               = sdwan_other_feature_profile.other_feature_profile[each.value.name].id
  access_port_dedicated            = try(each.value.ucse.cimc_access_port_dedicated, null)
  access_port_shared_failover_type = try(each.value.ucse.cimc_access_port_shared_failover_type, null)
  access_port_shared_type          = try(each.value.ucse.cimc_access_port_shared_type, null)
  assign_priority                  = try(each.value.ucse.cimc_assign_priority, null)
  assign_priority_variable         = try("{{${each.value.ucse.cimc_assign_priority_variable}}}", null)
  bay                              = each.value.ucse.bay
  default_gateway                  = try(each.value.ucse.cimc_default_gateway, null)
  default_gateway_variable         = try("{{${each.value.ucse.cimc_default_gateway_variable}}}", null)
  interfaces = try(length(each.value.ucse.interfaces) == 0, true) ? null : [for i in each.value.ucse.interfaces : {
    interface_name              = try(i.interface_name, null)
    interface_name_variable     = try("{{${i.interface_name_variable}}}", null)
    ipv4_address                = try(i.ipv4_address, null)
    ipv4_address_variable       = try("{{${i.ipv4_address_variable}}}", null)
    ucse_interface_vpn          = try(i.vpn_id, null)
    ucse_interface_vpn_variable = try("{{${i.vpn_id_variable}}}", null)
  }]
  ipv4_address          = try(each.value.ucse.cimc_ipv4_address, null)
  ipv4_address_variable = try("{{${each.value.ucse.cimc_ipv4_address_variable}}}", null)
  slot                  = each.value.ucse.slot
  vlan_id               = try(each.value.ucse.cimc_vlan_id, null)
  vlan_id_variable      = try("{{${each.value.ucse.cimc_vlan_id_variable}}}", null)
}
