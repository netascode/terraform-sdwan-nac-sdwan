resource "sdwan_qos_map_policy_definition" "qos_map_policy_definition" {
  for_each    = { for d in try(local.localized_policies.definitions.qos_maps, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  qos_schedulers = try(length(each.value.qos_schedulers) == 0, true) ? null : [for s in each.value.qos_schedulers : {
    bandwidth_percent = s.bandwidth_percent
    buffer_percent    = s.buffer_percent
    burst             = try(s.burst_bytes, null)
    class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.class_map].id
    class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.class_map].version
    drop_type         = s.drop_type
    queue             = s.queue
    scheduling_type   = s.scheduling_type
  }]
}

resource "sdwan_rewrite_rule_policy_definition" "rewrite_rule_policy_definition" {
  for_each    = { for d in try(local.localized_policies.definitions.rewrite_rules, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  rules = try(length(each.value.rules) == 0, true) ? null : [for r in each.value.rules : {
    class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[r.class].id
    class_map_version = sdwan_class_map_policy_object.class_map_policy_object[r.class].version
    priority          = r.priority
    dscp              = r.dscp
    layer2_cos        = try(r.layer2_cos, null)
  }]
}

/*
resource "sdwan_acl_policy_definition" "ipv4_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.ipv4_access_control_lists, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    ip_type     = "ipv4"
    name        = try(s.name, null)
    base_action = s.base_action
    match_entries = try(length(s.match_criterias) == 0, true) ? null : [for m, v in s.match_criterias : {
      type                                 = s.match_criterias.field
      dscp                                 = s.match_criterias.field == "dscp" ? s.match_criterias.value : null
      source_ip                            = s.match_criterias.field == "sourceIp" ? s.match_criterias.value : null
      destination_ip                       = s.match_criterias.field == "destinationIp" ? s.match_criterias.value : null
      class_map_id                         = s.match_criterias.field == "class" ? sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.ref].id : null
      class_map_version                    = s.match_criterias.field == "class" ? sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.ref].version : null
      packet_length                        = s.match_criterias.field == "packetLength" ? s.match_criterias.value : null
      priority                             = s.match_criterias.field == "plp" ? s.match_criterias.value : null
      source_port                          = s.match_criterias.field == "sourcePort" ? s.match_criterias.value : null
      destination_port                     = s.match_criterias.field == "destinationPort" ? s.match_criterias.value : null
      source_data_prefix_list_id           = s.match_criterias.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].id : null
      source_data_prefix_list_version      = s.match_criterias.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].version : null
      destination_data_prefix_list_id      = s.match_criterias.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].id : null
      destination_data_prefix_list_version = s.match_criterias.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].version : null
      protocol                             = s.match_criterias.field == "protocol" ? s.match_criterias.value : null
      tcp                                  = s.match_criterias.field == "tcp" ? s.match_criterias.value : null
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
      type                                 = s.match_criterias.field
      source_ip                            = s.match_criterias.field == "sourceIp" ? s.match_criterias.value : null
      destination_ip                       = s.match_criterias.field == "destinationIp" ? s.match_criterias.value : null
      source_port                          = s.match_criterias.field == "sourcePort" ? s.match_criterias.value : null
      destination_port                     = s.match_criterias.field == "destinationPort" ? s.match_criterias.value : null
      source_data_prefix_list_id           = s.match_criterias.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].id : null
      source_data_prefix_list_version      = s.match_criterias.field == "sourceDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].version : null
      destination_data_prefix_list_id      = s.match_criterias.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].id : null
      destination_data_prefix_list_version = s.match_criterias.field == "destinationDataPrefixList" ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.ref].version : null
    }]
    action_entries = try(length(s.actions) == 0, true) ? null : [for a in s.actions : {
      type         = a.type
      counter_name = a.type == "count" ? tostring(a.parameter) : null
    }]
  }]
}
*/

resource "sdwan_route_policy_definition" "route_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.route_policies, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.parameters.default_action.type, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    ip_type     = s.ip_type
    name        = "Route"
    base_action = s.base_action
    match_entries = try(length(s.match_criterias) == 0, true) ? null : flatten([for mtype, match in s.match_criterias: {
      type = (
        mtype == "prefix_list" ? "address" :
        mtype == "as_path_list" ? "asPath" :
        mtype == "standard_community_lists" ? "advancedCommunity" :
        mtype == "expanded_community_lists" ? "expandedCommunity" :
        mtype == "extended_community_list" ? "extCommunity" :
        mtype == "bgp_local_preference" ? "localPreference" :
        mtype == "metric" ? "metric" :
        mtype == "next_hop_prefix_list" ? "nextHop" :
        mtype == "origin" ? "origin" :
        mtype == "peer" ? "peer" :
        mtype == "omp_tag" ? "ompTag" :
        mtype == "ospf_tag" ? "ospfTag" : null
      )
      prefix_list_id                  = mtype == "prefix_list" ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[match].id : null
      prefix_list_version             = mtype == "prefix_list" ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[match].version : null
      as_path_list_id                 = mtype == "as_path_list" ? sdwan_as_path_list_policy_object.as_path_list_policy_object[match].id : null
      as_path_list_version            = mtype == "as_path_list" ? sdwan_as_path_list_policy_object.as_path_list_policy_object[match].version : null
      community_list_ids              = mtype == "standard_community_lists" ? [for com_list in try(match, null) : sdwan_standard_community_list_policy_object.standard_community_list_policy_object[com_list].id] : null
      community_list_versions         = mtype == "standard_community_lists" ? [for com_list in try(match, null) : sdwan_standard_community_list_policy_object.standard_community_list_policy_object[com_list].version] : null
      #community_list_match_flag       = mtype == "standard_community_lists" ? try(tostring(match), null) : null
      expanded_community_list_id      = mtype == "expanded_community_lists" ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[match].id : null
      expanded_community_list_version = mtype == "expanded_community_lists" ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[match].version : null
      extended_community_list_id      = mtype == "extended_community_list" ? sdwan_extended_community_list_policy_object.extended_community_list_policy_object[match].id : null
      extended_community_list_version = mtype == "extended_community_list" ? sdwan_extended_community_list_policy_object.extended_community_list_policy_object[match].id : null
      local_preference                = mtype == "bgp_local_preference" ? try(tonumber(match), null) : null
      metric                          = mtype == "metric" ? try(tonumber(match), null) : null
      next_hop                        = mtype == "next_hop_prefix_list" ? try(tostring(match), null) : null
      origin                          = mtype == "origin" ? try(tostring(match), null) : null
      peer                            = mtype == "peer" ? try(tostring(match), null) : null
      omp_tag                         = mtype == "omp_tag" ? try(tonumber(match), null) : null
      ospf_tag                        = mtype == "ospf_tag" ? try(tonumber(match), null) : null
    }])
    
    action_entries = try(length(s.actions) == 0, true) ? null : flatten([for atype, action in try(s.actions, []) : {
      type = (
        atype == "aggregator" ? "aggregator" :
        atype == "aggregator_ip" ? "aggregator" :
        atype == "prepend_as_paths" ? "asPath" :
        atype == "exclude_as_paths" ? "asPath" :
        atype == "atomic_aggregate" ? "atomicAggregate" :
        atype == "communities" ? "community" :
        atype == "community_additive" ? "communityAdditive" :
        atype == "local_preference" ? "localPreference" :
        atype == "metric" ? "metric" :
        atype == "weight" ? "weight" :
        atype == "metric_type" ? "metricType" :
        atype == "next_hop" ? "nextHop" :
        atype == "omp_tag" ? "ompTag" :
        atype == "ospf_tag" ? "ospfTag" :
        atype == "origin" ? "origin" :
        atype == "originator" ? "originator" : null
      )
      aggregator            = atype == "aggregator" ? try(tonumber(action), null) : null
      aggregator_ip_address = atype == "aggregator_ip" ? try(tostring(action), null) : null
      as_path_prepend       = atype == "prepend_as_paths" ? join(" ", [for as in action : as]) : null
      as_path_exclude       = atype == "exclude_as_paths" ? join(" ", [for as in action : as]) : null
      atomic_aggregate      = atype == "atomic_aggregate" ? try(tobool(action), null) : null
      community             = atype == "communities" ? join(" ", [for c in action : c]) : null
      community_additive    = atype == "community_additive" ? try(tobool(action), null) : null
      local_preference      = atype == "local_preference" ? try(tonumber(action), null) : null
      metric                = atype == "metric" ? try(tonumber(action), null) : null
      weight                = atype == "weight" ? try(tonumber(action), null) : null
      metric_type           = atype == "metric_type" ? try(tostring(action), null) : null
      next_hop              = atype == "next_hop" ? try(tostring(action), null) : null
      omp_tag               = atype == "omp_tag" ? try(tonumber(action), null) : null
      ospf_tag              = atype == "ospf_tag" ? try(tonumber(action), null) : null
      origin                = atype == "origin" ? try(tostring(action), null) : null
      originator            = atype == "originator" ? try(tostring(action), null) : null
    }])
  }]
}

resource "sdwan_localized_policy" "localized_policy" {
  for_each                      = { for p in try(local.localized_policies.feature_policies, {}) : p.name => p }
  name                          = each.value.name
  description                   = each.value.description
  flow_visibility_ipv4          = try(each.value.ipv4_flow_visibility, null)
  flow_visibility_ipv6          = try(each.value.ipv6_flow_visibility, null)
  application_visibility_ipv4   = try(each.value.ipv4_application_visibility, null)
  application_visibility_ipv6   = try(each.value.ipv6_application_visibility, null)
  implicit_acl_logging          = try(each.value.implicit_acl_logging, null)
  log_frequency                 = try(each.value.log_frequency, null)
  ipv4_visibility_cache_entries = try(each.value.ipv4_visibility_cache_entries, null)
  ipv6_visibility_cache_entries = try(each.value.ipv6_visibility_cache_entries, null)
  definitions = flatten([for def, pol in try(each.value.definitions, []) : [for policy in pol : {
    type = (
      def == "qos_maps" ? "qosMap" :
      def == "rewrite_rules" ? "rewriteRule" :
      def == "route_policies" ? "vedgeRoute" : null
    )
    id = (
      def == "qos_maps" ? sdwan_qos_map_policy_definition.qos_map_policy_definition[policy].id :
      def == "rewrite_rules" ? sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition[policy].id :
      def == "route_policies" ? sdwan_route_policy_definition.route_policy_definition[policy].id : null
    )
  }]])
  #definitions = try(each.value.definitions, false) ? [ for x in concat( 
  #  [for qosmap in try(each.value.definitions.qos_maps, []) : { "type" : "qosMap", "id" : sdwan_qos_map_policy_definition.qos_map_policy_definition[qosmap].id } ],
  #  [for rule in try(each.value.definitions.rewrite_rules, []) : { "type" : "rewriteRule", "id" : sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition[rule].id } ],
  #  [for rp in try(each.value.definitions.route_policies, []) : {"type" : "vedgeRoute", "id" : sdwan_route_policy_definition.route_policy_definition[rp].id } ],
  #  [for acl in try(each.value.definitions.ipv4_access_control_lists, []) : {"type" : "acl", "id" : sdwan_acl_policy_definition.acl_policy_definition[acl].id } ]
  #  [for dap in try(each.value.definitions.ipv4_device_access_policies, []) : {"type" : "deviceAccessPolicy", "id" : sdwan_device_acl_policy_definition.device_acl_policy_definition[dap].id } ]

  #  try(d.qos_maps, false) ? [for map in d.qos_maps : { "type" : "qosMap", "id" : "${sdwan_qos_map_policy_definition.qos_map_policy_definition[map].id}"}] : null,  )
}
