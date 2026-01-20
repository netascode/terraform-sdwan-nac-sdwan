resource "sdwan_application_priority_qos_policy" "application_priority_qos_policy" {
  for_each = {
    for qos_item in flatten([
      for profile in try(local.feature_profiles.application_priority_profiles, []) : [
        for qos_policy in try(profile.qos_policies, []) : {
          profile    = profile
          qos_policy = qos_policy
        }
      ]
    ])
    : "${qos_item.profile.name}-${qos_item.qos_policy.name}" => qos_item
  }
  name                       = each.value.qos_policy.name
  description                = null # not supported in the UI
  feature_profile_id         = sdwan_application_priority_feature_profile.application_priority_feature_profile[each.value.profile.name].id
  target_interfaces          = try(each.value.qos_policy.target_interfaces, null)
  target_interfaces_variable = try("{{${each.value.qos_policy.target_interfaces_variable}}}", null)
  qos_schedulers = try(length(each.value.qos_policy.qos_schedulers) == 0, true) ? null : [for s in each.value.qos_policy.qos_schedulers : {
    bandwidth           = s.bandwidth_percent
    drops               = s.drops
    forwarding_class_id = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].id
    queue               = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].entries[0].queue
    scheduling_type     = sdwan_policy_object_class_map.policy_object_class_map[s.forwarding_class].entries[0].queue == "0" ? "llq" : "wrr"
  }]
}

# Application Priority Traffic Policy
resource "sdwan_application_priority_traffic_policy_policy" "application_priority_traffic_policy" {
  for_each = {
    for tp_item in flatten([
      for profile in try(local.feature_profiles.application_priority_profiles, []) : [
        for traffic_policy in try(profile.traffic_policies, []) : {
          profile        = profile
          traffic_policy = traffic_policy
        }
      ]
    ])
    : "${tp_item.profile.name}-${tp_item.traffic_policy.name}" => tp_item
  }
  name               = each.value.traffic_policy.name
  description        = null # not supported in the UI
  feature_profile_id = sdwan_application_priority_feature_profile.application_priority_feature_profile[each.value.profile.name].id
  default_action     = each.value.traffic_policy.default_action
  vpns               = try(each.value.traffic_policy.vpns, null)
  direction          = each.value.traffic_policy.direction
  sequences = [for seq in each.value.traffic_policy.sequences : {
    # Transform user-friendly sequence IDs (1,2,3,4) to API sequence IDs (1,11,21,31)
    # Formula: (user_id - 1) * 10 + 1
    sequence_id   = (seq.sequence_id - 1) * 10 + 1
    sequence_name = seq.sequence_name
    base_action   = seq.base_action
    protocol      = seq.protocol
    match_entries = try(seq.match_criterias, null) == null ? null : flatten([
      # Application matching
      try(seq.match_criterias.application_list, null) != null ? [{
        application_list_id = sdwan_policy_object_application_list.policy_object_application_list[seq.match_criterias.application_list].id
      }] : [],
      try(seq.match_criterias.dns, null) != null ? [{
        dns = seq.match_criterias.dns
      }] : [],
      try(seq.match_criterias.dns_application_list, null) != null ? [{
        dns_application_list_id = sdwan_policy_object_application_list.policy_object_application_list[seq.match_criterias.dns_application_list].id
      }] : [],
      # Destination criteria
      try(seq.match_criterias.destination_data_ipv4_prefix_list, null) != null ? [{
        destination_data_ipv4_prefix_list_id = sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[seq.match_criterias.destination_data_ipv4_prefix_list].id
      }] : [],
      try(seq.match_criterias.destination_data_ipv6_prefix_list, null) != null ? [{
        destination_data_ipv6_prefix_list_id = sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[seq.match_criterias.destination_data_ipv6_prefix_list].id
      }] : [],
      try(seq.match_criterias.destination_ipv4_prefix, null) != null ? [{
        destination_ipv4_prefix = seq.match_criterias.destination_ipv4_prefix
      }] : [],
      try(seq.match_criterias.destination_ipv6_prefix, null) != null ? [{
        destination_ipv6_prefix = seq.match_criterias.destination_ipv6_prefix
      }] : [],
      try(length(seq.match_criterias.destination_ports) == 0, true) ? [] : [{
        destination_ports = [for p in seq.match_criterias.destination_ports : tostring(p)]
      }],
      try(seq.match_criterias.destination_region, null) != null ? [{
        destination_region = seq.match_criterias.destination_region
      }] : [],
      try(seq.match_criterias.dscps, null) != null ? [{
        dscps = seq.match_criterias.dscps
      }] : [],
      try(seq.match_criterias.icmp_messages, null) != null ? [{
        icmp_messages = seq.match_criterias.icmp_messages
      }] : [],
      try(seq.match_criterias.icmp6_messages, null) != null ? [{
        icmp6_messages = seq.match_criterias.icmp6_messages
      }] : [],
      try(seq.match_criterias.packet_length, null) != null ? [{
        packet_length = seq.match_criterias.packet_length
      }] : [],
      try(seq.match_criterias.protocols, null) != null ? [{
        protocols = seq.match_criterias.protocols
      }] : [],
      # SaaS
      try(seq.match_criterias.saas_application_list, null) != null ? [{
        saas_application_list_id = sdwan_policy_object_application_list.policy_object_application_list[seq.match_criterias.saas_application_list].id
      }] : [],
      try(seq.match_criterias.service_areas, null) != null ? [{
        service_areas = seq.match_criterias.service_areas
      }] : [],
      # Source criteria
      try(seq.match_criterias.source_data_ipv4_prefix_list, null) != null ? [{
        source_data_ipv4_prefix_list_id = sdwan_policy_object_data_ipv4_prefix_list.policy_object_data_ipv4_prefix_list[seq.match_criterias.source_data_ipv4_prefix_list].id
      }] : [],
      try(seq.match_criterias.source_data_ipv6_prefix_list, null) != null ? [{
        source_data_ipv6_prefix_list_id = sdwan_policy_object_data_ipv6_prefix_list.policy_object_data_ipv6_prefix_list[seq.match_criterias.source_data_ipv6_prefix_list].id
      }] : [],
      try(seq.match_criterias.source_ipv4_prefix, null) != null ? [{
        source_ipv4_prefix = seq.match_criterias.source_ipv4_prefix
      }] : [],
      try(seq.match_criterias.source_ipv6_prefix, null) != null ? [{
        source_ipv6_prefix = seq.match_criterias.source_ipv6_prefix
      }] : [],
      try(length(seq.match_criterias.source_ports) == 0, true) ? [] : [{
        source_ports = [for p in seq.match_criterias.source_ports : tostring(p)]
      }],
      try(seq.match_criterias.tcp, null) != null ? [{
        tcp = seq.match_criterias.tcp
      }] : [],
      try(seq.match_criterias.traffic_category, null) != null ? [{
        traffic_category = lookup({
          "optimize-allow" = "optimizeAllow"
        }, seq.match_criterias.traffic_category, seq.match_criterias.traffic_category)
      }] : [],
      try(seq.match_criterias.traffic_class, null) != null ? [{
        traffic_class = seq.match_criterias.traffic_class
      }] : [],
      try(seq.match_criterias.traffic_to, null) != null ? [{
        traffic_to = seq.match_criterias.traffic_to
      }] : []
    ])
    actions = try(seq.actions, null) == null ? null : flatten([
      try(seq.actions.sla_class, null) != null ? [{
        sla_classes = flatten([
          try(seq.actions.sla_class.sla_class_list, null) != null ? [{ sla_class_list_id = sdwan_policy_object_sla_class_list.policy_object_sla_class_list[seq.actions.sla_class.sla_class_list].id }] : [],
          try(seq.actions.sla_class.preferred_colors, null) != null ? [{ preferred_colors = seq.actions.sla_class.preferred_colors }] : [],
          try(seq.actions.sla_class.preferred_color_group_list, null) != null ? [{ preferred_color_group_list_id = sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group[seq.actions.sla_class.preferred_color_group_list].id }] : [],
          try(seq.actions.sla_class.strict, null) != null ? [{ strict = seq.actions.sla_class.strict }] : [],
          try(seq.actions.sla_class.fallback_to_best_path, null) != null ? [{ fallback_to_best_path = seq.actions.sla_class.fallback_to_best_path }] : [],
          try(seq.actions.sla_class.preferred_remote_colors, null) != null ? [{ preferred_remote_colors = seq.actions.sla_class.preferred_remote_colors }] : [],
          try(seq.actions.sla_class.remote_color_restrict, null) != null ? [{ remote_color_restrict = seq.actions.sla_class.remote_color_restrict }] : [],
        ])
      }] : [],
      try(seq.actions.backup_sla_preferred_colors, null) != null ? [{
        backup_sla_preferred_colors = seq.actions.backup_sla_preferred_colors
      }] : [],
      try(seq.actions.log, null) != null ? [{
        log = seq.actions.log
      }] : [],
      try(seq.actions.count, null) != null ? [{
        count = seq.actions.count
      }] : [],
      try(seq.actions.nat_vpn, null) != null ? [{
        nat_vpn            = try(seq.actions.nat_vpn.nat_vpn_0, null)
        nat_bypass         = try(seq.actions.nat_vpn.bypass, null)
        nat_fallback       = try(seq.actions.nat_vpn.fallback, null)
        nat_dia_interfaces = try(seq.actions.nat_vpn.dia_interfaces, null)
        nat_dia_pools      = try(seq.actions.nat_vpn.dia_pools, null) != null ? [for p in seq.actions.nat_vpn.dia_pools : tostring(p)] : null
      }] : [],
      try(seq.actions.nat_pool, null) != null ? [{
        nat_pool = seq.actions.nat_pool
      }] : [],
      try(seq.actions.cloud_saas, null) != null ? [{
        cloud_saas = seq.actions.cloud_saas
      }] : [],
      try(seq.actions.cloud_probe, null) != null ? [{
        cloud_probe = seq.actions.cloud_probe
      }] : [],
      try(seq.actions.cflowd, null) != null ? [{
        cflowd = seq.actions.cflowd
      }] : [],
      try(seq.actions.sig_sse, null) != null ? [{
        secure_internet_gateway      = try(seq.actions.sig_sse.internet_gateway, null)
        secure_service_edge          = try(seq.actions.sig_sse.service_edge, null)
        secure_service_edge_instance = try(seq.actions.sig_sse.service_edge_instance, null) != null ? (seq.actions.sig_sse.service_edge_instance == "cisco-secure-access" ? "Cisco-Secure-Access" : seq.actions.sig_sse.service_edge_instance == "zscaler" ? "zScaler" : seq.actions.sig_sse.service_edge_instance) : null
        fallback_to_routing          = try(seq.actions.sig_sse.fallback_to_routing, null)
      }] : [],
      try(seq.actions.redirect_dns_field, null) != null && try(seq.actions.redirect_dns_value, null) != null ? [{
        redirect_dns_field = seq.actions.redirect_dns_field == "ip-address" ? "ipAddress" : seq.actions.redirect_dns_field == "dns-host" ? "dnsHost" : seq.actions.redirect_dns_field
        redirect_dns_value = seq.actions.redirect_dns_value
      }] : [],
      try(seq.actions.appqoe_optimization, null) != null ? [{
        appqoe_dre_optimization   = try(seq.actions.appqoe_optimization.dre_optimization, null)
        appqoe_service_node_group = try(seq.actions.appqoe_optimization.service_node_group, null)
        appqoe_tcp_optimization   = try(seq.actions.appqoe_optimization.tcp_optimization, null)
      }] : [],
      try(seq.actions.loss_correct_type, null) != null ? [{
        loss_correct_type = lookup({
          "fec-adaptive"       = "fecAdaptive"
          "fec-always"         = "fecAlways"
          "packet-duplication" = "packetDuplication"
        }, seq.actions.loss_correct_type, seq.actions.loss_correct_type)
        loss_correct_fec_threshold = try(seq.actions.loss_correct_fec_threshold, null)
      }] : [],
      # =======================================================================
      # ACTIONS INSIDE set_parameters
      # =======================================================================
      anytrue([
        try(seq.actions.dscp, null) != null,
        try(seq.actions.forwarding_class_list, null) != null,
        try(seq.actions.local_tloc, null) != null,
        try(seq.actions.next_hop_ipv4, null) != null,
        try(seq.actions.next_hop_ipv6, null) != null,
        try(seq.actions.next_hop_loose, null) != null,
        try(seq.actions.policer_list, null) != null,
        try(seq.actions.preferred_color_group_list, null) != null,
        try(seq.actions.preferred_remote_colors, null) != null,
        try(seq.actions.preferred_remote_color_restrict, null) != null,
        try(seq.actions.service, null) != null,
        try(seq.actions.service_chain, null) != null,
        try(seq.actions.tloc, null) != null,
        try(seq.actions.vpn, null) != null
        ]) ? [{
        set_parameters = flatten([
          try(seq.actions.dscp, null) != null ? [{
            dscp = seq.actions.dscp
          }] : [],
          try(seq.actions.forwarding_class_list, null) != null ? [{
            forwarding_class_list_id = sdwan_policy_object_class_map.policy_object_class_map[seq.actions.forwarding_class_list].id
          }] : [],
          try(seq.actions.local_tloc, null) != null ? [{
            local_tloc_list_colors        = try(seq.actions.local_tloc.colors, null)
            local_tloc_list_encapsulation = try(seq.actions.local_tloc.encapsulation, null)
            local_tloc_list_restrict      = try(seq.actions.local_tloc.restrict, null)
          }] : [],
          try(seq.actions.next_hop_ipv4, null) != null ? [{
            next_hop_ipv4 = seq.actions.next_hop_ipv4
          }] : [],
          try(seq.actions.next_hop_ipv6, null) != null ? [{
            next_hop_ipv6 = seq.actions.next_hop_ipv6
          }] : [],
          # Next Hop Loose (no data_path → separate object, MUST be separate from next_hop_ipv4/ipv6!)
          try(seq.actions.next_hop_loose, null) != null ? [{
            next_hop_loose = seq.actions.next_hop_loose
          }] : [],
          try(seq.actions.policer_list, null) != null ? [{
            policer_id = sdwan_policy_object_policer.policy_object_policer[seq.actions.policer_list].id
          }] : [],
          try(seq.actions.preferred_color_group_list, null) != null ? [{
            preferred_color_group_id = sdwan_policy_object_preferred_color_group.policy_object_preferred_color_group[seq.actions.preferred_color_group_list].id
          }] : [],
          try(seq.actions.preferred_remote_colors, null) != null || try(seq.actions.preferred_remote_color_restrict, null) != null ? [{
            preferred_remote_colors         = try(seq.actions.preferred_remote_colors, null)
            preferred_remote_color_restrict = try(seq.actions.preferred_remote_color_restrict, null)
          }] : [],
          try(seq.actions.service, null) != null ? [{
            service_type               = try(seq.actions.service.type, null) != null ? upper(seq.actions.service.type) : null
            service_vpn                = try(seq.actions.service.vpn, null)
            service_tloc_color         = try(seq.actions.service.tloc_color, null)
            service_tloc_encapsulation = try(seq.actions.service.tloc_encapsulation, null)
            service_tloc_ip            = try(seq.actions.service.tloc_ip, null)
            service_tloc_list_id       = try(seq.actions.service.tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.actions.service.tloc_list].id : null
            service_local              = try(seq.actions.service.local, null)
            service_restrict           = try(seq.actions.service.restrict, null)
          }] : [],
          try(seq.actions.service_chain, null) != null ? [{
            service_chain_type                = try(seq.actions.service_chain.type, null) != null ? upper(seq.actions.service_chain.type) : null
            service_chain_vpn                 = try(seq.actions.service_chain.vpn, null)
            service_chain_local               = try(seq.actions.service_chain.local, null)
            service_chain_fallback_to_routing = try(seq.actions.service_chain.fallback_to_routing, null) != null ? !seq.actions.service_chain.fallback_to_routing : null
            service_chain_tloc_color          = try(seq.actions.service_chain.tloc_color, null)
            service_chain_tloc_encapsulation  = try(seq.actions.service_chain.tloc_encapsulation, null)
            service_chain_tloc_ip             = try(seq.actions.service_chain.tloc_ip, null)
            service_chain_tloc_list_id        = try(seq.actions.service_chain.tloc_list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.actions.service_chain.tloc_list].id : null
          }] : [],
          try(seq.actions.tloc, null) != null ? [{
            tloc_ip            = try(seq.actions.tloc.ip, null)
            tloc_color         = try(seq.actions.tloc.color, null)
            tloc_encapsulation = try(seq.actions.tloc.encapsulation, null)
            tloc_list_id       = try(seq.actions.tloc.list, null) != null ? sdwan_policy_object_tloc_list.policy_object_tloc_list[seq.actions.tloc.list].id : null
          }] : [],
          try(seq.actions.vpn, null) != null ? [{
            vpn = seq.actions.vpn
          }] : []
        ])
      }] : []
    ])
  }]
}
