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

resource "sdwan_ipv4_acl_policy_definition" "ipv4_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.ipv4_access_control_lists, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    name        = try(s.name, "Access Control List")
    base_action = s.base_action
    match_entries = !(can(s.match_criterias.class) ||
      can(s.match_criterias.destination_data_prefix_list) ||
      can(s.match_criterias.destination_ip_prefix) ||
      can(s.match_criterias.destination_ports) ||
      can(s.match_criterias.dscp) ||
      can(s.match_criterias.packet_length) ||
      can(s.match_criterias.priority) ||
      can(s.match_criterias.protocols) ||
      can(s.match_criterias.source_data_prefix_list) ||
      can(s.match_criterias.source_ip_prefix) ||
      can(s.match_criterias.source_ports) ||
      can(s.match_criterias.tcp)) ? null : flatten([
      try(s.match_criterias.class, null) == null ? [] : [{
        type              = "class"
        class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.class].id
        class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.class].version
      }],
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                      = "destinationDataPrefixList"
        destination_data_ipv4_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_ipv4_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_ip_prefix, null) == null ? [] : [{
        type           = "destinationIp"
        destination_ip = s.match_criterias.destination_ip_prefix
      }],
      try(s.match_criterias.destination_ports, null) == null && try(s.match_criterias.destination_port_ranges, null) == null ? [] : [{
        type              = "destinationPort"
        destination_ports = join(" ", concat([for p in try(s.match_criterias.destination_ports, []) : p], [for r in try(s.match_criterias.destination_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.dscp, null) == null ? [] : [{
        type = "dscp"
        dscp = s.match_criterias.dscp
      }],
      try(s.match_criterias.packet_length, null) == null ? [] : [{
        type          = "packetLength"
        packet_length = s.match_criterias.packet_length
      }],
      try(s.match_criterias.priority, null) == null ? [] : [{
        type     = "plp"
        priority = s.match_criterias.priority
      }],
      try(s.match_criterias.protocols, null) == null ? [] : [{
        type     = "protocol"
        protocol = join(" ", [for p in s.match_criterias.protocols : p])
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                                 = "sourceDataPrefixList"
        source_data_ipv4_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_ipv4_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_ip_prefix, null) == null ? [] : [{
        type      = "sourceIp"
        source_ip = s.match_criterias.source_ip_prefix
      }],
      try(s.match_criterias.source_ports, null) == null && try(s.match_criterias.source_port_ranges, null) == null ? [] : [{
        type         = "sourcePort"
        source_ports = join(" ", concat([for p in try(s.match_criterias.source_ports, []) : p], [for r in try(s.match_criterias.source_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.tcp, null) == null ? [] : [{
        type = "tcp"
        tcp  = s.match_criterias.tcp
      }]
    ])

    action_entries = !(can(s.actions.counter_name) ||
      can(s.actions.class) ||
      can(s.actions.log) ||
      can(s.actions.mirror_list) ||
      can(s.actions.policer) ||
      can(s.actions.next_hop) ||
      can(s.actions.dscp)) ? null : flatten([
      try(s.actions.counter_name, null) == null ? [] : [{
        type         = "count"
        counter_name = s.actions.counter_name
      }],
      try(s.actions.class, null) == null ? [] : [{
        type              = "class"
        class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.actions.class].id
        class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.actions.class].version
      }],
      try(s.actions.log, null) == null ? [] : [{
        type = "log"
        log  = s.actions.log
      }],
      try(s.actions.mirror_list, null) == null ? [] : [{
        type           = "mirror"
        mirror_id      = sdwan_mirror_policy_object.mirror_policy_object[s.actions.mirror_list].id
        mirror_version = sdwan_mirror_policy_object.mirror_policy_object[s.actions.mirror_list].version
      }],
      try(s.actions.policer, null) == null ? [] : [{
        type            = "policer"
        policer_id      = sdwan_policer_policy_object.policer_policy_object[s.actions.policer].id
        policer_version = sdwan_policer_policy_object.policer_policy_object[s.actions.policer].version
      }],
      try(s.actions.next_hop, null) == null && try(s.actions.dscp, null) == null ? [] : [{
        type = "set"
        set_parameters = flatten([
          try(s.actions.dscp, null) == null ? [] : [{
            type = "dscp"
            dscp = s.actions.dscp
          }],
          try(s.actions.next_hop, null) == null ? [] : [{
            type     = "nextHop"
            next_hop = s.actions.next_hop
          }]
        ])
      }]
    ])
  }]
}

resource "sdwan_ipv6_acl_policy_definition" "ipv6_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.ipv6_access_control_lists, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    name        = try(s.name, "Access Control List")
    base_action = s.base_action
    match_entries = !(can(s.match_criterias.class) ||
      can(s.match_criterias.destination_data_prefix_list) ||
      can(s.match_criterias.destination_ip_prefix) ||
      can(s.match_criterias.destination_port) ||
      can(s.match_criterias.next_header) ||
      can(s.match_criterias.packet_length) ||
      can(s.match_criterias.priority) ||
      can(s.match_criterias.source_data_prefix_list) ||
      can(s.match_criterias.source_ip_prefix) ||
      can(s.match_criterias.source_ports) ||
      can(s.match_criterias.tcp) ||
      can(s.match_criterias.traffic_class)) ? null : flatten([
      try(s.match_criterias.class, null) == null ? [] : [{
        type              = "class"
        class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.class].id
        class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.match_criterias.class].version
      }],
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                      = "destinationDataIpv6PrefixList"
        destination_data_ipv6_prefix_list_id      = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_ipv6_prefix_list_version = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_ip_prefix, null) == null ? [] : [{
        type           = "destinationIpv6"
        destination_ip = s.match_criterias.destination_ip_prefix
      }],
      try(s.match_criterias.destination_port, null) == null ? [] : [{
        type              = "destinationPort"
        destination_ports = s.match_criterias.destination_port
      }],
      try(s.match_criterias.next_header, null) == null ? [] : [{
        type        = "nextHeader"
        next_header = s.match_criterias.next_header
      }],
      try(s.match_criterias.packet_length, null) == null ? [] : [{
        type          = "packetLength"
        packet_length = s.match_criterias.packet_length
      }],
      try(s.match_criterias.priority, null) == null ? [] : [{
        type     = "plp"
        priority = s.match_criterias.priority
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                                 = "sourceDataIpv6PrefixList"
        source_data_ipv6_prefix_list_id      = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_ipv6_prefix_list_version = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_ip_prefix, null) == null ? [] : [{
        type      = "sourceIpv6"
        source_ip = s.match_criterias.source_ip_prefix
      }],
      try(s.match_criterias.source_ports, null) == null && try(s.match_criterias.source_port_ranges, null) == null ? [] : [{
        type         = "sourcePort"
        source_ports = join(" ", concat([for p in try(s.match_criterias.source_ports, []) : p], [for r in try(s.match_criterias.source_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.tcp, null) == null ? [] : [{
        type = "tcp"
        tcp  = s.match_criterias.tcp
      }],
      try(s.match_criterias.traffic_class, null) == null ? [] : [{
        type          = "trafficClass"
        traffic_class = s.match_criterias.traffic_class
      }]
    ])

    action_entries = !(can(s.actions.counter_name) ||
      can(s.actions.class) ||
      can(s.actions.log) ||
      can(s.actions.mirror_list) ||
      can(s.actions.policer) ||
      can(s.actions.next_hop) ||
      can(s.actions.dscp)) ? null : flatten([
      try(s.actions.counter_name, null) == null ? [] : [{
        type         = "count"
        counter_name = s.actions.counter_name
      }],
      try(s.actions.class, null) == null ? [] : [{
        type              = "class"
        class_map_id      = sdwan_class_map_policy_object.class_map_policy_object[s.actions.class].id
        class_map_version = sdwan_class_map_policy_object.class_map_policy_object[s.actions.class].version
      }],
      try(s.actions.log, null) == null ? [] : [{
        type = "log"
        log  = s.actions.log
      }],
      try(s.actions.mirror_list, null) == null ? [] : [{
        type           = "mirror"
        mirror_id      = sdwan_mirror_policy_object.mirror_policy_object[s.actions.mirror_list].id
        mirror_version = sdwan_mirror_policy_object.mirror_policy_object[s.actions.mirror_list].version
      }],
      try(s.actions.policer, null) == null ? [] : [{
        type            = "policer"
        policer_id      = sdwan_policer_policy_object.policer_policy_object[s.actions.policer].id
        policer_version = sdwan_policer_policy_object.policer_policy_object[s.actions.policer].version
      }],
      try(s.actions.next_hop, null) == null && try(s.actions.dscp, null) == null ? [] : [{
        type = "set"
        set_parameters = flatten([
          try(s.actions.traffic_class, null) == null ? [] : [{
            type          = "trafficClass"
            traffic_class = s.actions.traffic_class
          }],
          try(s.actions.next_hop, null) == null ? [] : [{
            type     = "nextHop"
            next_hop = s.actions.next_hop
          }]
        ])
      }]
    ])
  }]
}

resource "sdwan_ipv4_device_acl_policy_definition" "ipv4_device_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.ipv4_device_access_policies, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    name        = try(s.sequenceName, "Device Access Control List")
    base_action = s.base_action
    match_entries = !(can(s.match_criterias.destination_data_prefix_list) ||
      can(s.match_criterias.destination_ip_prefix) ||
      can(s.match_criterias.destination_port) ||
      can(s.match_criterias.source_data_prefix_list) ||
      can(s.match_criterias.source_ip_prefix) ||
      can(s.match_criterias.source_ports)) ? null : flatten([
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                      = "destinationDataPrefixList"
        destination_data_ipv4_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_ipv4_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_ip_prefix, null) == null ? [] : [{
        type           = "destinationIp"
        destination_ip = s.match_criterias.destination_ip_prefix
      }],
      try(s.match_criterias.destination_port, null) == null ? [] : [{
        type             = "destinationPort"
        destination_port = s.match_criterias.destination_port
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                                 = "sourceDataPrefixList"
        source_data_ipv4_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_ipv4_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_ip_prefix, null) == null ? [] : [{
        type      = "sourceIp"
        source_ip = s.match_criterias.source_ip_prefix
      }],
      try(s.match_criterias.source_ports, null) == null ? [] : [{
        type         = "sourcePort"
        source_ports = join(" ", [for p in try(s.match_criterias.source_ports, []) : p])
      }]
    ])
    action_entries = try(s.counter_name, null) == null ? null : [{
      type         = "count"
      counter_name = s.counter_name
    }]
  }]
}

resource "sdwan_ipv6_device_acl_policy_definition" "ipv6_device_acl_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.ipv6_device_access_policies, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    name        = try(s.sequenceName, "Device Access Control List")
    base_action = s.base_action
    match_entries = !(can(s.match_criterias.destination_data_prefix_list) ||
      can(s.match_criterias.destination_ip_prefix) ||
      can(s.match_criterias.destination_port) ||
      can(s.match_criterias.source_data_prefix_list) ||
      can(s.match_criterias.source_ip_prefix) ||
      can(s.match_criterias.source_ports)) ? null : flatten([
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                      = "destinationDataIpv6PrefixList"
        destination_data_ipv6_prefix_list_id      = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_ipv6_prefix_list_version = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_ip_prefix, null) == null ? [] : [{
        type           = "destinationIpv6"
        destination_ip = s.match_criterias.destination_ip_prefix
      }],
      try(s.match_criterias.destination_port, null) == null ? [] : [{
        type             = "destinationPort"
        destination_port = s.match_criterias.destination_port
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                                 = "sourceDataIpv6PrefixList"
        source_data_ipv6_prefix_list_id      = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_ipv6_prefix_list_version = sdwan_data_ipv6_prefix_list_policy_object.data_ipv6_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_ip_prefix, null) == null ? [] : [{
        type      = "sourceIpv6"
        source_ip = s.match_criterias.source_ip_prefix
      }],
      try(s.match_criterias.source_ports, null) == null ? [] : [{
        type         = "sourcePort"
        source_ports = join(" ", [for p in try(s.match_criterias.source_ports, []) : p])
      }]
    ])
    action_entries = try(s.counter_name, null) == null ? null : [{
      type         = "count"
      counter_name = s.counter_name
    }]
  }]
}

resource "sdwan_route_policy_definition" "route_policy_definition" {
  for_each       = { for d in try(local.localized_policies.definitions.route_policies, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.parameters.default_action.type, null)
  sequences = try(length(each.value.sequences) == 0, true) ? null : [for s in each.value.sequences : {
    id          = s.id
    ip_type     = s.ip_type
    name        = try(s.name, "Route")
    base_action = s.base_action
    match_entries = !(can(s.match_criterias.prefix_list) ||
      can(s.match_criterias.prefix_list) ||
      can(s.match_criterias.as_path_list) ||
      can(s.match_criterias.standard_community_lists) ||
      can(s.match_criterias.expanded_community_list) ||
      can(s.match_criterias.extended_community_list) ||
      can(s.match_criterias.bgp_local_preference) ||
      can(s.match_criterias.metric) ||
      can(s.match_criterias.next_hop_prefix_list) ||
      can(s.match_criterias.origin) ||
      can(s.match_criterias.peer) ||
      can(s.match_criterias.omp_tag) ||
      can(s.match_criterias.ospf_tag)) ? null : flatten([
      try(s.match_criterias.prefix_list, null) == null ? [] : [{
        type                = "address"
        prefix_list_id      = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.prefix_list].id
        prefix_list_version = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.prefix_list].version
      }],
      try(s.match_criterias.as_path_list, null) == null ? [] : [{
        type                 = "asPath"
        as_path_list_id      = sdwan_as_path_list_policy_object.as_path_list_policy_object[s.match_criterias.as_path_list].id
        as_path_list_version = sdwan_as_path_list_policy_object.as_path_list_policy_object[s.match_criterias.as_path_list].version
      }],
      try(s.match_criterias.standard_community_lists, null) == null ? [] : [{
        type                      = "advancedCommunity"
        community_list_ids        = [for com_list in try(s.match_criterias.standard_community_lists, null) : sdwan_standard_community_list_policy_object.standard_community_list_policy_object[com_list].id]
        community_list_versions   = [for com_list in try(s.match_criterias.standard_community_lists, null) : sdwan_standard_community_list_policy_object.standard_community_list_policy_object[com_list].version]
        community_list_match_flag = try(s.match_criterias.standard_community_lists_criteria, null)
      }],
      try(s.match_criterias.expanded_community_list, null) == null ? [] : [{
        type                            = "expandedCommunity"
        expanded_community_list_id      = sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[s.match_criterias.expanded_community_list].id
        expanded_community_list_version = sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[s.match_criterias.expanded_community_list].version
      }],
      try(s.match_criterias.extended_community_list, null) == null ? [] : [{
        type                            = "extCommunity"
        extended_community_list_id      = sdwan_extended_community_list_policy_object.extended_community_list_policy_object[s.match_criterias.extended_community_list].id
        extended_community_list_version = sdwan_extended_community_list_policy_object.extended_community_list_policy_object[s.match_criterias.extended_community_list].version
      }],
      try(s.match_criterias.bgp_local_preference, null) == null ? [] : [{
        type             = "localPreference"
        local_preference = s.match_criterias.bgp_local_preference
      }],
      try(s.match_criterias.metric, null) == null ? [] : [{
        type   = "metric"
        metric = s.match_criterias.metric
      }],
      try(s.match_criterias.next_hop_prefix_list, null) == null ? [] : [{
        type                         = "nextHop"
        next_hop_prefix_list_id      = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.next_hop_prefix_list].id
        next_hop_prefix_list_version = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.next_hop_prefix_list].version
      }],
      try(s.match_criterias.origin, null) == null ? [] : [{
        type   = "origin"
        origin = s.match_criterias.origin
      }],
      try(s.match_criterias.peer, null) == null ? [] : [{
        type = "peer"
        peer = s.match_criterias.peer
      }],
      try(s.match_criterias.omp_tag, null) == null ? [] : [{
        type    = "ompTag"
        omp_tag = s.match_criterias.omp_tag
      }],
      try(s.match_criterias.ospf_tag, null) == null ? [] : [{
        type     = "ospfTag"
        ospf_tag = s.match_criterias.ospf_tag
      }]
    ])

    action_entries = !(can(s.actions.aggregator_ip) ||
      can(s.actions.prepend_as_paths) ||
      can(s.actions.exclude_as_paths) ||
      can(s.actions.atomic_aggregate) ||
      can(s.actions.communities) ||
      can(s.actions.community_additive) ||
      can(s.actions.local_preference) ||
      can(s.actions.metric) ||
      can(s.actions.weight) ||
      can(s.actions.metric_type) ||
      can(s.actions.next_hop) ||
      can(s.actions.omp_tag) ||
      can(s.actions.ospf_tag) ||
      can(s.actions.origin) ||
      can(s.actions.originator)) ? null : flatten([
      try(s.actions.aggregator_ip, null) == null || try(s.actions.aggregator, null) == null ? [] : [{
        type                  = "aggregator"
        aggregator            = s.actions.aggregator
        aggregator_ip_address = s.actions.aggregator_ip
      }],
      try(s.actions.prepend_as_paths, null) == null ? [] : [{
        type            = "asPath"
        as_path_prepend = join(" ", [for as in s.actions.prepend_as_paths : as])
      }],
      try(s.actions.exclude_as_paths, null) == null ? [] : [{
        type            = "asPath"
        as_path_exclude = join(" ", [for as in s.actions.exclude_as_paths : as])
      }],
      try(s.actions.atomic_aggregate, null) == null ? [] : [{
        type             = "atomicAggregate"
        atomic_aggregate = s.actions.atomic_aggregate
      }],
      try(s.actions.communities, null) == null ? [] : [{
        type      = "community"
        community = join(" ", [for c in s.actions.communities : c])
      }],
      try(s.actions.community_additive, null) == null ? [] : [{
        type               = "communityAdditive"
        community_additive = s.actions.community_additive
      }],
      try(s.actions.local_preference, null) == null ? [] : [{
        type             = "localPreference"
        local_preference = s.actions.local_preference
      }],
      try(s.actions.metric, null) == null ? [] : [{
        type   = "metric"
        metric = s.actions.metric
      }],
      try(s.actions.weight, null) == null ? [] : [{
        type   = "weight"
        weight = s.actions.weight
      }],
      try(s.actions.metric_type, null) == null ? [] : [{
        type        = "metricType"
        metric_type = s.actions.metric_type
      }],
      try(s.actions.next_hop, null) == null ? [] : [{
        type     = "nextHop"
        next_hop = s.actions.next_hop
      }],
      try(s.actions.omp_tag, null) == null ? [] : [{
        type    = "ompTag"
        omp_tag = s.actions.omp_tag
      }],
      try(s.actions.ospf_tag, null) == null ? [] : [{
        type     = "ospfTag"
        ospf_tag = s.actions.ospf_tag
      }],
      try(s.actions.origin, null) == null ? [] : [{
        type   = "origin"
        origin = s.actions.origin
      }],
      try(s.actions.originator, null) == null ? [] : [{
        type       = "originator"
        originator = s.actions.originator
      }]
    ])
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
  definitions = flatten([
    try(each.value.definitions.qos_maps, null) == null ? [] : [for qosmap in each.value.definitions.qos_maps : [{
      type = "qosMap"
      id   = sdwan_qos_map_policy_definition.qos_map_policy_definition[qosmap].id
    }]],
    try(each.value.definitions.rewrite_rules, null) == null ? [] : [for rule in each.value.definitions.rewrite_rules : [{
      type = "rewriteRule"
      id   = sdwan_rewrite_rule_policy_definition.rewrite_rule_policy_definition[rule].id
    }]],
    try(each.value.definitions.route_policies, null) == null ? [] : [for policy in each.value.definitions.route_policies : [{
      type = "vedgeRoute"
      id   = sdwan_route_policy_definition.route_policy_definition[policy].id
    }]],
    try(each.value.definitions.ipv4_access_control_lists, null) == null ? [] : [for acl in each.value.definitions.ipv4_access_control_lists : [{
      type = "acl"
      id   = sdwan_ipv4_acl_policy_definition.ipv4_acl_policy_definition[acl].id
    }]],
    try(each.value.definitions.ipv6_access_control_lists, null) == null ? [] : [for acl in each.value.definitions.ipv6_access_control_lists : [{
      type = "aclv6"
      id   = sdwan_ipv6_acl_policy_definition.ipv6_acl_policy_definition[acl].id
    }]],
    try(each.value.definitions.ipv4_device_access_policies, null) == null ? [] : [for acl in each.value.definitions.ipv4_device_access_policies : [{
      type = "deviceAccessPolicy"
      id   = sdwan_ipv4_device_acl_policy_definition.ipv4_device_acl_policy_definition[acl].id
    }]],
    try(each.value.definitions.ipv6_device_access_policies, null) == null ? [] : [for acl in each.value.definitions.ipv6_device_access_policies : [{
      type = "deviceAccessPolicyv6"
      id   = sdwan_ipv6_device_acl_policy_definition.ipv6_device_acl_policy_definition[acl].id
    }]]
  ])
}

