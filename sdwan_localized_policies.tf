resource "sdwan_qos_map_policy_definition" "qos_map_policy_definition" {
  for_each    = { for d in try(local.localized_policies.definitions.qosMap, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  qos_schedulers = try(length(each.value.parameters.definition.qosSchedulers) == 0, true) ? null : [for s in each.value.parameters.definition.qosSchedulers : {
    bandwidth_percent = s.bandwidthPercent
    buffer_percent    = s.bufferPercent
    burst             = try(s.burst, null)
    class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.classMapRef].id
    class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.classMapRef].version
    drop_type         = s.drops
    queue             = s.queue
    scheduling_type   = s.scheduling
  }]
}

resource "sdwan_rewrite_rule_policy_definition" "rewrite_rule_policy_definition" {
  for_each    = { for d in try(local.localized_policies.definitions.rewriteRule, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  rules = try(length(each.value.parameters.definition.rules) == 0, true) ? null : [for r in each.value.parameters.definition.rules : {
    class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[r.class].id
    class_map_version = sdwan_class_map_policy_object.class_map_policy_object[r.class].version
    priority          = r.plp
    dscp              = r.dscp
    layer2_cos        = try(r.layer2cos, null)
  }]
}

resource "sdwan_acl_policy_definition" "acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.acl, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.parameters.defaultAction.type, null)
  sequences = try(length(each.value.parameters.sequences) == 0, true) ? null : [for s in each.value.parameters.sequences : {
    id          = s.sequenceId
    ip_type     = s.sequenceIpType
    name        = try(s.sequenceName, null)
    base_action = s.baseAction
    match_entries = try(length(s.match.entries) == 0, true) ? null : [for m in s.match.entries : {
      type                                 = m.field
      dscp                                 = m.field == "dscp" ? m.value : null
      source_ip                            = m.field == "sourceIp" ? m.value : null
      destination_ip                       = m.field == "destinationIp" ? m.value : null
      class_map_id                         = m.field == "class" ? sdwan_class_map_policy_object.class_map_policy_object[m.ref].id : null
      class_map_version                    = m.field == "class" ? sdwan_class_map_policy_object.class_map_policy_object[m.ref].version : null
      packet_length                        = m.field == "packetLength" ? m.value : null
      priority                             = m.field == "plp" ? m.value : null
      source_port                          = m.field == "sourcePort" ? m.value : null
      destination_port                     = m.field == "destinationPort" ? m.value : null
      source_data_prefix_list_id           = m.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].id : null
      source_data_prefix_list_version      = m.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].version : null
      destination_data_prefix_list_id      = m.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].id : null
      destination_data_prefix_list_version = m.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].version : null
      protocol                             = m.field == "protocol" ? m.value : null
      tcp                                  = m.field == "tcp" ? m.value : null
    }]
    action_entries = try(length(s.actions) == 0, true) ? null : [for a in s.actions : {
      type              = a.type
      class_map_id      = a.type == "class" ? sdwan_class_map_policy_object.class_map_policy_object[a.parameter.ref].id : null
      class_map_version = a.type == "class" ? sdwan_class_map_policy_object.class_map_policy_object[a.parameter.ref].version : null
      counter_name      = a.type == "count" ? tostring(a.parameter) : null
      dscp              = a.type == "set" ? (a.parameter[0].field == "dscp" ? a.parameter[0].value : null) : null
      mirror_id         = a.type == "mirror" ? sdwan_mirror_policy_object.mirror_policy_object[a.parameter.ref].id : null
      mirror_version    = a.type == "mirror" ? sdwan_mirror_policy_object.mirror_policy_object[a.parameter.ref].version : null
      next_hop          = a.type == "set" ? (a.parameter[0].field == "nextHop" ? a.parameter[0].value : null) : null
      policer_id        = a.type == "policer" ? sdwan_policer_policy_object.policer_policy_object[a.parameter.ref].id : null
      policer_version   = a.type == "policer" ? sdwan_policer_policy_object.policer_policy_object[a.parameter.ref].version : null
      set_parameters = try(length(a.parameter) == 0 || a.type != "set", true) ? null : [for p in a.parameter : {
        type     = p.field
        dscp     = p.field == "dscp" ? p.value : null
        next_hop = p.field == "nextHop" ? p.value : null
      }]
    }]
  }]
}

resource "sdwan_device_acl_policy_definition" "device_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.deviceAccessPolicy, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.parameters.defaultAction.type, null)
  sequences = try(length(each.value.parameters.sequences) == 0, true) ? null : [for s in each.value.parameters.sequences : {
    id          = s.sequenceId
    ip_type     = s.sequenceIpType
    name        = try(s.sequenceName, null)
    base_action = s.baseAction
    match_entries = try(length(s.match.entries) == 0, true) ? null : [for m in s.match.entries : {
      type                                 = m.field
      source_ip                            = m.field == "sourceIp" ? m.value : null
      destination_ip                       = m.field == "destinationIp" ? m.value : null
      source_port                          = m.field == "sourcePort" ? m.value : null
      destination_port                     = m.field == "destinationPort" ? m.value : null
      source_data_prefix_list_id           = m.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].id : null
      source_data_prefix_list_version      = m.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].version : null
      destination_data_prefix_list_id      = m.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].id : null
      destination_data_prefix_list_version = m.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[m.ref].version : null
    }]
    action_entries = try(length(s.actions) == 0, true) ? null : [for a in s.actions : {
      type         = a.type
      counter_name = a.type == "count" ? tostring(a.parameter) : null
    }]
  }]
}

resource "sdwan_route_policy_definition" "route_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.vedgeRoute, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.parameters.defaultAction.type, null)
  sequences = try(length(each.value.parameters.sequences) == 0, true) ? null : [for s in each.value.parameters.sequences : {
    id          = s.sequenceId
    ip_type     = s.sequenceIpType
    name        = try(s.sequenceName, null)
    base_action = s.baseAction
    match_entries = try(length(s.match.entries) == 0, true) ? null : [for m in s.match.entries : {
      type                            = m.field == "community" ? "advancedCommunity" : m.field
      prefix_list_id                  = m.field == "address" ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[m.ref].id : null
      prefix_list_version             = m.field == "address" ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[m.ref].version : null
      as_path_list_id                 = m.field == "asPath" ? sdwan_as_path_list_policy_object.as_path_list_policy_object[m.ref].id : null
      as_path_list_version            = m.field == "asPath" ? sdwan_as_path_list_policy_object.as_path_list_policy_object[m.ref].version : null
      community_list_ids              = m.field == "community" ? [sdwan_standard_community_list_policy_object.standard_community_list_policy_object[m.ref].id] : null
      community_list_versions         = m.field == "community" ? [sdwan_standard_community_list_policy_object.standard_community_list_policy_object[m.ref].version] : null
      community_list_match_flag       = m.field == "community" ? m.matchFlag : null
      expanded_community_list_id      = m.field == "expandedCommunity" ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[m.ref].id : null
      expanded_community_list_version = m.field == "expandedCommunity" ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[m.ref].version : null
      extended_community_list_id      = m.field == "extCommunity" ? sdwan_extended_community_list_policy_object.extended_community_list_policy_object[m.ref].id : null
      extended_community_list_version = m.field == "extCommunity" ? sdwan_extended_community_list_policy_object.extended_community_list_policy_object[m.ref].version : null
      local_preference                = m.field == "localPreference" ? m.value : null
      metric                          = m.field == "metric" ? m.value : null
      next_hop                        = m.field == "nextHop" ? m.value : null
      origin                          = m.field == "origin" ? m.value : null
      peer                            = m.field == "peer" ? m.value : null
      origin                          = m.field == "origin" ? m.value : null
      omp_tag                         = m.field == "ompTag" ? m.value : null
      ospf_tag                        = m.field == "ospfTag" ? m.value : null
    }]
    action_entries = try(length(s.actions[0].parameter) == 0, true) ? null : [for a in s.actions[0].parameter : {
      type                  = a.field
      aggregator            = a.field == "aggregator" ? try(tonumber(a.value.aggregator), null) : null
      aggregator_ip_address = a.field == "aggregator" ? try(tostring(a.value.ipaddress), null) : null
      as_path_prepend       = a.field == "asPath" ? try(tostring(a.value.prepend), null) : null
      as_path_exclude       = a.field == "asPath" ? try(tostring(a.value.exclude), null) : null
      atomic_aggregate      = a.field == "atomicAggregate" ? try(tobool(a.value), null) : null
      community             = a.field == "community" ? try(tostring(a.value), null) : null
      community_additive    = a.field == "communityAdditive" ? try(tobool(a.value), null) : null
      local_preference      = a.field == "localPreference" ? try(tonumber(a.value), null) : null
      metric                = a.field == "metric" ? try(tonumber(a.value), null) : null
      weight                = a.field == "weight" ? try(tonumber(a.value), null) : null
      metric_type           = a.field == "metrictype" ? try(tostring(a.value), null) : null
      next_hop              = a.field == "nextHop" ? try(tostring(a.value), null) : null
      omp_tag               = a.field == "ompTag" ? try(tonumber(a.value), null) : null
      ospf_tag              = a.field == "ospfTag" ? try(tonumber(a.value), null) : null
      origin                = a.field == "origin" ? try(tostring(a.value), null) : null
      originator            = a.field == "originator" ? try(tostring(a.value), null) : null
    }]
  }]
}

resource "sdwan_localized_policy" "localized_policy" {
  for_each                      = { for p in try(local.localized_policies.policies.feature, {}) : p.name => p }
  name                          = each.value.name
  description                   = each.value.description
  flow_visibility_ipv4          = try(each.value.parameters.settings.flowVisibility, null)
  flow_visibility_ipv6          = try(each.value.parameters.settings.flowVisibilityIPv6, null)
  application_visibility_ipv4   = try(each.value.parameters.settings.appVisibility, null)
  application_visibility_ipv6   = try(each.value.parameters.settings.appVisibilityIPv6, null)
  implicit_acl_logging          = try(each.value.parameters.settings.implicitAclLogging, null)
  log_frequency                 = try(each.value.parameters.settings.logFrequency, null)
  ipv4_visibility_cache_entries = try(each.value.parameters.settings.ipVisibilityCacheEntries, null)
  ipv6_visibility_cache_entries = try(each.value.parameters.settings.ipV6VisibilityCacheEntries, null)
  definitions = try(length(each.value.parameters.assembly) == 0, true) ? null : [for d in each.value.parameters.assembly : {
    id = (
      d.type == "acl" ? sdwan_acl_policy_definition.acl_policy_definition[d.definitionName].id :
      d.type == "deviceAccessPolicy" ? sdwan_device_acl_policy_definition.device_acl_policy_definition[d.definitionName].id :
      d.type == "qosMap" ? sdwan_qos_map_policy_definition.qos_map_policy_definition[d.definitionName].id :
      d.type == "rewriteRule" ? sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition[d.definitionName].id :
      d.type == "vedgeRoute" ? sdwan_route_policy_definition.route_policy_definition[d.definitionName].id : null
    )
    version = (
      d.type == "acl" ? sdwan_acl_policy_definition.acl_policy_definition[d.definitionName].version :
      d.type == "deviceAccessPolicy" ? sdwan_device_acl_policy_definition.device_acl_policy_definition[d.definitionName].version :
      d.type == "qosMap" ? sdwan_qos_map_policy_definition.qos_map_policy_definition[d.definitionName].version :
      d.type == "rewriteRule" ? sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition[d.definitionName].version :
      d.type == "vedgeRoute" ? sdwan_route_policy_definition.route_policy_definition[d.definitionName].version : null
    )
    type = d.type
  }]
}
