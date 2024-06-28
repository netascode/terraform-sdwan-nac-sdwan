resource "sdwan_zone_based_firewall_policy_definition" "zone_based_firewall_policy_definition" {
  for_each       = { for p in try(local.security_policies.definitions.zone_based_firewall, {}) : p.name => p }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action_type, null)
  mode           = "security"
  rules = [for r in each.value.rules : {
    rule_order  = r.id
    rule_name   = r.name
    base_action = r.base_action
    action_entries = (
    try(r.actions.log, null) == true ? [{ type = "log" }] : null)
    match_entries = (
      try(r.match_criterias, null) == null ? null :
      flatten([
        try(r.match_criterias.source_data_prefix_lists, null) == null ? [] : [{
          type      = "sourceDataPrefixList"
          policy_id = join(" ", [for x in try(r.match_criterias.source_data_prefix_lists, []) : sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x].id])
        }],
        try(r.match_criterias.source_ip_prefix, null) == null ? [] : [{
          type  = "sourceIp"
          value = r.match_criterias.source_ip_prefix
        }],
        try(r.match_criterias.source_ip_prefix_variable, null) == null ? [] : [{
          type           = "sourceIp"
          value_variable = r.match_criterias.source_ip_prefix_variable
        }],
        try(r.match_criterias.source_fqdn, null) == null ? [] : [{
          type  = "sourceFqdn"
          value = r.match_criterias.source_fqdn
        }],
        try(r.match_criterias.source_geo_locations, null) == null ? [] : [{
          type  = "sourceGeoLocation"
          value = join(" ", concat([for p in try(r.match_criterias.source_geo_locations, []) : p]))
        }],
        try(r.match_criterias.source_ports, null) == null && try(r.match_criterias.source_port_ranges, null) == null ? [] : [{
          type  = "sourcePort"
          value = join(" ", concat([for p in try(r.match_criterias.source_ports, []) : p], [for s in try(r.match_criterias.source_port_ranges, []) : "${s.from}-${s.to}"]))
        }],
        try(r.match_criterias.source_fqdn_lists, null) == null ? [] : [{
          type      = "sourceFqdnList"
          policy_id = join(" ", [for x in try(r.match_criterias.source_fqdn_lists, []) : sdwan_data_fqdn_prefix_list_policy_object.fqdn_prefix_list_policy_object[x].id])
        }],
        try(r.match_criterias.destination_data_prefix_lists, null) == null ? [] : [{
          type      = "destinationDataPrefixList"
          policy_id = join(" ", [for x in try(r.match_criterias.destination_data_prefix_lists, []) : sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x].id])
        }],
        try(r.match_criterias.destination_ip_prefix, null) == null ? [] : [{
          type  = "destinationIp"
          value = r.match_criterias.destination_ip_prefix
        }],
        try(r.match_criterias.destination_geo_locations, null) == null ? [] : [{
          type  = "destinationGeoLocation"
          value = join(" ", concat([for p in try(r.match_criterias.destination_geo_locations, []) : p]))
        }],
        try(r.match_criterias.destination_ip_prefix_variable, null) == null ? [] : [{
          type           = "destinationIp"
          value_variable = r.match_criterias.destination_ip_prefix_variable
        }],
        try(r.match_criterias.destination_fqdn, null) == null ? [] : [{
          type  = "destinationFqdn"
          value = r.match_criterias.destination_fqdn
        }],
        try(r.match_criterias.destination_ports, null) == null && try(r.match_criterias.destination_port_ranges, null) == null ? [] : [{
          type  = "destinationPort"
          value = join(" ", concat([for p in try(r.match_criterias.destination_ports, []) : p], [for s in try(r.match_criterias.destination_port_ranges, []) : "${s.from}-${s.to}"]))
        }],
        try(r.match_criterias.destination_fqdn_lists, null) == null ? [] : [{
          type      = "destinationFqdnList"
          policy_id = join(" ", [for x in try(r.match_criterias.destination_fqdn_lists, []) : sdwan_data_fqdn_prefix_list_policy_object.fqdn_prefix_list_policy_object[x].id])
        }],
        try(r.match_criterias.protocols, null) == null ? [] : [{
          type  = "protocol"
          value = join(" ", concat([for p in try(r.match_criterias.protocols, []) : p]))
        }],
        try(r.match_criterias.protocol_names, null) == null ? [] : [{
          type  = "protocolName"
          value = join(" ", concat([for p in try(r.match_criterias.protocol_names, []) : p]))
        }],
        try(r.match_criterias.local_application_list, null) == null ? [] : [{
          type      = "appList"
          policy_id = sdwan_local_application_list_policy_object.local_application_list_policy_object[r.match_criterias.local_application_list].id
        }],
    ]))
  }]
  apply_zone_pairs = [for zp in each.value.zone_pairs : {
    source_zone      = try(zp.source_zone, null) == "self_zone" ? "self" : sdwan_zone_list_policy_object.zone_list_policy_object[zp.source_zone].id
    destination_zone = try(zp.destination_zone, null) == "self_zone" ? "self" : sdwan_zone_list_policy_object.zone_list_policy_object[zp.destination_zone].id
  }]
}


resource "sdwan_security_policy" "security_policy" {
  for_each    = { for p in try(local.security_policies.feature_policies, {}) : p.name => p }
  name        = each.value.name
  description = each.value.description
  mode        = "security"
  use_case    = each.value.use_case
  definitions = flatten([
    try(each.value.firewall_policies, null) == null ? [] :
    [for fp in each.value.firewall_policies : {
      type = "zoneBasedFW"
      id   = sdwan_zone_based_firewall_policy_definition.zone_based_firewall_policy_definition[fp].id
    }],
    try(each.value.intrusion_prevention_policy, null) == null ? [] : [{
      type = "intrusionPrevention"
      id   = sdwan_intrusion_prevention_policy_definition.intrusion_prevention_policy_definition[each.value.intrusion_prevention_policy].id
    }]
  ])
  direct_internet_applications = (
    try(each.value.additional_settings.firewall.direct_internet_applications, null) == true ? "allow" :
  try(each.value.additional_settings.firewall.direct_internet_applications, null) == false ? "deny" : null)
  tcp_syn_flood_limit            = try(each.value.additional_settings.firewall.tcp_syn_flood_limit, null)
  high_speed_logging_vpn         = try(each.value.additional_settings.firewall.high_speed_logging.vpn_id, null)
  high_speed_logging_server_ip   = try(each.value.additional_settings.firewall.high_speed_logging.server_ip, null)
  high_speed_logging_server_port = try(each.value.additional_settings.firewall.high_speed_logging.server_port, null)
  audit_trail = (
    try(each.value.additional_settings.firewall.audit_trail, null) == true ? "on" :
  try(each.value.additional_settings.firewall.audit_trail, null) == false ? "off" : null)
  match_statistics_per_filter = (
    try(each.value.additional_settings.firewall.match_stats_per_filter, null) == true ? "on" :
  try(each.value.additional_settings.firewall.match_stats_per_filter, null) == false ? "off" : null)
  failure_mode = try(each.value.additional_settings.ips_url_amp.failure_mode, null)
  logging = try(each.value.additional_settings.ips_url_amp.external_syslog_server, null) == null ? null : [{
    external_syslog_server_ip  = each.value.additional_settings.ips_url_amp.external_syslog_server.server_ip
    external_syslog_server_vpn = each.value.additional_settings.ips_url_amp.external_syslog_server.vpn_id
  }]
}


resource "sdwan_intrusion_prevention_policy_definition" "intrusion_prevention_policy_definition" {
  for_each        = { for p in try(local.security_policies.definitions.intrusion_prevention, {}) : p.name => p }
  name            = each.value.name
  description     = each.value.description
  mode            = "security"
  inspection_mode = try(each.value.inspection_mode, null)
  log_level       = try(each.value.log_level, null)
  signature_set   = try(each.value.signature_set, null)
  # ips_signature_list_id = try(each.value.ips_signature_list, null)
  target_vpns = try(each.value.target_vpns, null) != null ? [for x in try(each.value.target_vpns, []) : x] : null
} 