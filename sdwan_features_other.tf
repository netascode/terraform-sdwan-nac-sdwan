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
