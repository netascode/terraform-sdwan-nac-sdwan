resource "sdwan_activate_centralized_policy" "activate_centralized_policy" {
  for_each = { for p in keys(try(local.centralized_policies, {})) : p => p
  if p == "activated_policy" }
  id      = try(local.centralized_policies.activated_policy, null) != null ? sdwan_centralized_policy.centralized_policy[local.centralized_policies.activated_policy].id : null
  version = try(local.centralized_policies.activated_policy, null) != null ? sdwan_centralized_policy.centralized_policy[local.centralized_policies.activated_policy].version : null
}

resource "sdwan_centralized_policy" "centralized_policy" {
  for_each    = { for p in try(local.centralized_policies.feature_policies, {}) : p.name => p }
  name        = each.value.name
  description = each.value.description
  definitions = concat(
    [for d in try(each.value.custom_control_topology, []) : {
      id      = sdwan_custom_control_topology_policy_definition.custom_control_topology_policy_definition[d.policy_definition].id
      version = sdwan_custom_control_topology_policy_definition.custom_control_topology_policy_definition[d.policy_definition].version
      type    = "control"
      entries = [for h in keys(try(d.site_region_list, [])) : {
        direction = (
          h == "site_lists_in" ? "all" :  // should be accepting in and out for Custom control, but not available in provider
          h == "site_lists_out" ? "all" : // should be accepting in and out for Custom control, but not available in provider
          null
        )
        site_list_ids = (
          h == "site_lists_in" ? [for x in try(d.site_region_list.site_lists_in, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] :
          h == "site_lists_out" ? [for x in try(d.site_region_list.site_lists_out, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] :
          null
        )
        site_list_versions = (
          h == "site_lists_in" ? [for x in try(d.site_region_list.site_lists_in, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] :
          h == "site_lists_out" ? [for x in try(d.site_region_list.site_lists_out, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] :
          null
        )
        // should also be supporting region list and region for Custom control, but not documented in Provider itself
    }] }],
    [for d in try(each.value.hub_and_spoke_topology, []) : {
      id      = sdwan_hub_and_spoke_topology_policy_definition.hub_and_spoke_topology_policy_definition[d.policy_definition].id
      version = sdwan_hub_and_spoke_topology_policy_definition.hub_and_spoke_topology_policy_definition[d.policy_definition].version
      type    = "hubAndSpoke"
    }],
    [for d in try(each.value.mesh_topology, []) : {
      id      = sdwan_mesh_topology_policy_definition.mesh_topology_policy_definition[d.policy_definition].id
      version = sdwan_mesh_topology_policy_definition.mesh_topology_policy_definition[d.policy_definition].version
      type    = "mesh"
    }],
    [for d in try(each.value.vpn_membership, []) : {
      id      = sdwan_vpn_membership_policy_definition.vpn_membership_policy_definition[d.policy_definition].id
      version = sdwan_vpn_membership_policy_definition.vpn_membership_policy_definition[d.policy_definition].version
      type    = "vpnMembershipGroup"
    }],
    [for d in try(each.value.traffic_data, []) : {
      id      = sdwan_traffic_data_policy_definition.traffic_data_policy_definition[d.policy_definition].id
      version = sdwan_traffic_data_policy_definition.traffic_data_policy_definition[d.policy_definition].version
      type    = "data"
      entries = try(d.site_region_vpn, null) != null ? [for h in(try(d.site_region_vpn, [])) : {
        direction          = try(h.direction, null) != null ? h.direction : null
        site_list_ids      = [for x in try(h.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id]
        site_list_versions = [for x in try(h.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version]
        vpn_list_ids       = [for x in try(h.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].id]
        vpn_list_versions  = [for x in try(h.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].version]
      }] : null
    }],
    [for d in try(each.value.cflowd, []) : {
      id      = sdwan_cflowd_policy_definition.cflowd_policy_definition[d.policy_definition].id
      version = sdwan_cflowd_policy_definition.cflowd_policy_definition[d.policy_definition].version
      type    = "cflowd"
      entries = [{
        site_list_ids      = [for x in try(d.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id]
        site_list_versions = [for x in try(d.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version]
      }]
    }],
    [for d in try(each.value.application_aware_routing, []) : {
      id      = sdwan_application_aware_routing_policy_definition.application_aware_routing_policy_definition[d.policy_definition].id
      version = sdwan_application_aware_routing_policy_definition.application_aware_routing_policy_definition[d.policy_definition].version
      type    = "appRoute"
      entries = [{
        site_list_ids      = [for x in try(d.site_region_vpn.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id]
        site_list_versions = [for x in try(d.site_region_vpn.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version]
        vpn_list_ids       = [for x in try(d.site_region_vpn.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].id]
        vpn_list_versions  = [for x in try(d.site_region_vpn.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].version]
      }]
    }]
  )
}

resource "sdwan_custom_control_topology_policy_definition" "custom_control_topology_policy_definition" {
  for_each       = { for d in try(local.centralized_policies.definitions.control_policy.custom_control_topology, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action_type, null)
  sequences = [for s in each.value.sequences : {
    id          = s.id
    name        = s.name
    type        = try(s.type, null)
    ip_type     = try(s.ip_type, null)
    base_action = try(s.base_action, null) //  not taking effect. Plan file doesnt inclue this attribute
    match_entries = try(s.match_criterias, null) != null ? [for x in s.match_criterias : {
      type = (
        try(x.color_list, null) != null ? "colorList" :
        try(x.community, null) != null ? "community" :
        try(x.omp_tag, null) != null ? "ompTag" :
        try(x.expanded_community, null) != null ? "expandedCommunity" :
        try(x.origin, null) != null ? "origin" : // Possible Provider issue │ Attribute sequences[0].match_entries[5].origin value must be one of: ["igp" "egp" "incomplete"], got: "bgp".
        try(x.originator, null) != null ? "originator" :
        try(x.preference, null) != null ? "preference" :
        try(x.site_list, null) != null ? "siteList" : // is mutually exclusive with siteID in GUI, but provider allows both to be simultaneously defined
        try(x.site_id, null) != null ? "siteId" :     // is mutually exclusive with siteList in GUI, but provider allows both to be simultaneously defined
        try(x.path_type, null) != null ? "pathType" :
        try(x.tloc_list, null) != null ? "tlocList" : // is mutually exclusive with tloc in GUI, but provider allows both to be simultaneously defined
        try(x.tloc, null) != null ? "tloc" :          // is mutually exclusive with tlocList in GUI, but provider allows both to be simultaneously defined
        try(x.vpn_list, null) != null ? "vpnList" :
        try(x.vpn, null) != null ? "vpn" :
        try(x.ipv4_prefix_list, null) != null ? "prefixList" :
        try(x.carrier, null) != null ? "carrier" :
        try(x.domain_id, null) != null ? "domainId" :
        try(x.group_id, null) != null ? "groupId" :
        null
      )
      color_list_id                   = (try(x.color_list, null) != null ? sdwan_color_list_policy_object.color_list_policy_object[x.color_list].id : null)
      color_list_version              = (try(x.color_list, null) != null ? sdwan_color_list_policy_object.color_list_policy_object[x.color_list].version : null)
      community_list_id               = (try(x.community, null) != null ? sdwan_standard_community_list_policy_object.standard_community_list_policy_object[x.community].id : null)
      community_list_version          = (try(x.community, null) != null ? sdwan_standard_community_list_policy_object.standard_community_list_policy_object[x.community].version : null)
      omp_tag                         = (try(x.omp_tag, null) != null ? x.omp_tag : null)
      expanded_community_list_id      = (try(x.expanded_community, null) != null ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[x.expanded_community].id : null)
      expanded_community_list_version = (try(x.expanded_community, null) != null ? sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[x.expanded_community].version : null)
      origin                          = (try(x.origin, null) != null ? x.origin : null)
      originator                      = (try(x.originator, null) != null ? x.originator : null)
      preference                      = (try(x.preference, null) != null ? x.preference : null)
      site_list_id                    = (try(x.site_list, null) != null ? sdwan_site_list_policy_object.site_list_policy_object[x.site_list].id : null)
      site_list_version               = (try(x.site_list, null) != null ? sdwan_site_list_policy_object.site_list_policy_object[x.site_list].version : null)
      site_id                         = (try(x.site_id, null) != null ? x.site_id : null)
      path_type                       = (try(x.path_type, null) != null ? x.path_type : null)
      tloc_list_id                    = (try(x.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[x.tloc_list].id : null)
      tloc_list_version               = (try(x.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[x.tloc_list].version : null)
      tloc_ip                         = (try(x.tloc, null) != null ? x.tloc.ip : null)
      tloc_color                      = (try(x.tloc, null) != null ? x.tloc.color : null)
      tloc_encapsulation              = (try(x.tloc, null) != null ? x.tloc.encap : null)
      vpn_list_id                     = (try(x.vpn_list, null) != null ? sdwan_vpn_list_policy_object.vpn_list_policy_object[x.vpn_list].id : null)
      vpn_list_version                = (try(x.vpn_list, null) != null ? sdwan_vpn_list_policy_object.vpn_list_policy_object[x.vpn_list].version : null)
      vpn_id                          = (try(x.vpn, null) != null ? x.vpn : null)
      prefix_list_id                  = (try(x.ipv4_prefix_list, null) != null ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[x.ipv4_prefix_list].id : null)
      prefix_list_version             = (try(x.ipv4_prefix_list, null) != null ? sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[x.ipv4_prefix_list].version : null)
      carrier                         = (try(x.carrier, null) != null ? x.carrier : null)
      domain_id                       = (try(x.domain_id, null) != null ? x.domain_id : null)
      group_id                        = (try(x.group_id, null) != null ? x.group_id : null)
    }] : null
    action_entries = (try(s.actions, null) != null) ? [for y in s.actions : {
      type = (
        try(y.set_parameters, null) != null ? "set" :
        try(y.export_to_parameter != null) ? "exportTo" :
        null
      )
      set_parameters = try(y.set_parameters, null) != null ? [for z in try(y.set_parameters, null) : {
        type = (
          try(z.community, null) != null ? "community" :
          try(z.community_additive, null) != null ? "communityAdditive" :
          try(z.omp_tag, null) != null ? "ompTag" :
          try(z.preference, null) != null ? "preference" :
          try(z.tloc_action, null) != null ? "tlocAction" :
          try(z.service, null) != null ? "service" :
          try(z.tloc_list, null) != null ? "tlocList" : // is mutually exclusive with tloc in GUI, but provider allows both to be simultaneously defined
          try(z.tloc, null) != null ? "tloc" :          // is mutually exclusive with tlocList in GUI, but provider allows both to be simultaneously defined
          null
        )
        community                  = (try(z.community, null) != null ? z.community : null)
        community_additive         = (try(z.community_additive, null) != null ? z.community_additive : null)
        omp_tag                    = (try(z.omp_tag, null) != null ? z.omp_tag : null)
        preference                 = (try(z.preference, null) != null ? z.preference : null)
        tloc_action                = (try(z.tloc_action, null) != null ? z.tloc_action : null)
        service_type               = (try(z.service, null) != null ? z.service.type : null)
        service_vpn_id             = (try(z.service, null) != null ? z.service.vpn : null)
        service_tloc_list_id       = (try(z.service.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.service.tloc_list].id : null)
        service_tloc_list_version  = (try(z.service.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.service.tloc_list].version : null)
        service_tloc_ip            = (try(z.service.tloc, null) != null ? z.service.tloc.ip : null)
        service_tloc_color         = (try(z.service.tloc, null) != null ? z.service.tloc.color : null)
        service_tloc_encapsulation = (try(z.service.tloc, null) != null ? z.service.tloc.encap : null)
        tloc_list_id               = (try(z.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.tloc_list].id : null)
        tloc_list_version          = (try(z.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.tloc_list].version : null)
        tloc_ip                    = (try(z.tloc, null) != null ? z.tloc.ip : null)
        tloc_color                 = (try(z.tloc, null) != null ? z.tloc.color : null)
        tloc_encapsulation         = (try(z.tloc, null) != null ? z.tloc.encap : null)
      }] : null
      export_to_vpn_list_id      = try(y.export_to_parameter.vpn_list, null) != null ? sdwan_vpn_list_policy_object.vpn_list_policy_object[y.export_to_parameter.vpn_list].id : null
      export_to_vpn_list_version = try(y.export_to_parameter.vpn_list, null) != null ? sdwan_vpn_list_policy_object.vpn_list_policy_object[y.export_to_parameter.vpn_list].version : null
    }] : null
  }]
}

resource "sdwan_hub_and_spoke_topology_policy_definition" "hub_and_spoke_topology_policy_definition" {
  for_each         = { for d in try(local.centralized_policies.definitions.control_policy.hub_and_spoke_topology, {}) : d.name => d }
  name             = each.value.name
  description      = each.value.description
  vpn_list_id      = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].id
  vpn_list_version = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].version
  topologies = try(length(each.value.hub_and_spoke_sites) == 0, true) ? null : [for t in each.value.hub_and_spoke_sites : {
    name = t.name
    spokes = try(length(t.spokes) == 0, true) ? null : [for s in t.spokes : {
      site_list_id      = sdwan_site_list_policy_object.site_list_policy_object[s.site_list].id
      site_list_version = sdwan_site_list_policy_object.site_list_policy_object[s.site_list].version
      hubs = try(length(s.hubs) == 0, true) ? null : [for h in s.hubs : {
        site_list_id      = sdwan_site_list_policy_object.site_list_policy_object[h.site_list].id
        site_list_version = sdwan_site_list_policy_object.site_list_policy_object[h.site_list].version
        }
      ]
    }]
  }]
}

resource "sdwan_mesh_topology_policy_definition" "mesh_topology_policy_definition" {
  for_each         = { for d in try(local.centralized_policies.definitions.control_policy.mesh_topology, {}) : d.name => d }
  name             = each.value.name
  description      = each.value.description
  vpn_list_id      = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].id
  vpn_list_version = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].version
  regions = try(length(each.value.mesh_groups) == 0, true) ? null : [for t in each.value.mesh_groups : {
    name               = t.name
    site_list_ids      = [for x in t.site_lists : sdwan_site_list_policy_object.site_list_policy_object[x].id]
    site_list_versions = [for x in t.site_lists : sdwan_site_list_policy_object.site_list_policy_object[x].version]
  }]
}

resource "sdwan_vpn_membership_policy_definition" "vpn_membership_policy_definition" {
  for_each    = { for d in try(local.centralized_policies.definitions.control_policy.vpn_membership, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  sites = try(length(each.value.groups) == 0, true) ? null : [for t in each.value.groups : {
    site_list_id      = sdwan_site_list_policy_object.site_list_policy_object[t.site_list].id
    site_list_version = sdwan_site_list_policy_object.site_list_policy_object[t.site_list].version
    vpn_list_ids      = [for x in t.vpn_lists : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].id]
    vpn_list_versions = [for x in t.vpn_lists : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].version]
  }]
}

resource "sdwan_traffic_data_policy_definition" "traffic_data_policy_definition" {
  for_each       = { for d in try(local.centralized_policies.definitions.data_policy.traffic_data, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = try(each.value.default_action_type, null)
  sequences = [for s in each.value.sequences : {
    id   = s.id
    name = s.name
    type = (
      s.type == "application_firewall" ? "applicationFirewall" :
      s.type == "qos" ? "qos" :
      s.type == "service_chaining" ? "serviceChaining" :
      s.type == "traffic_engineering" ? "trafficEngineering" :
      s.type == "custom" ? "data" :
      null
    )
    ip_type     = try(s.ip_type, null)
    base_action = try(s.base_action, null)
    match_entries = try(s.match_criterias, null) != null ? [for x in s.match_criterias : {
      type = (
        try(x.application_list, null) != null ? "appList" :
        try(x.dns_application_list, null) != null ? "dnsAppList" :
        try(x.dns, null) != null ? "dns" :
        try(x.dscp, null) != null ? "dscp" :
        try(x.packet_length, null) != null ? "packetLength" :
        try(x.plp, null) != null ? "plp" :
        try(x.protocols, null) != null ? "protocol" :
        try(x.source_data_prefix_list, null) != null ? "sourceDataPrefixList" :
        try(x.source_data_prefix, null) != null ? "sourceIp" :
        try(x.source_ports, null) != null ? "sourcePort" :
        try(x.destination_data_prefix_list, null) != null ? "destinationDataPrefixList" :
        try(x.destination_data_prefix, null) != null ? "destinationIp" :
        try(x.destination_region, null) != null ? "destinationRegion" :
        try(x.destination_ports, null) != null ? "destinationPort" :
        try(x.tcp, null) != null ? "tcp" :
        try(x.traffic_to, null) != null ? "trafficTo" :
        null
      )
      #application_list_id = (try(x, null) == "application_list" ? sdwan_application_list_policy_object.application_list_policy_object[yy].id : null)
      #application_list_version = (try(x, null) == "application_list" ? sdwan_application_list_policy_object.application_list_policy_object[yy].version : null)
      application_list_id                  = (try(x.application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.application_list].id : null)
      application_list_version             = (try(x.application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.application_list].version : null)
      dns_application_list_id              = (try(x.dns_application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.dns_application_list].id : null)
      dns_application_list_version         = (try(x.dns_application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.dns_application_list].version : null)
      dns                                  = (try(x.dns, null) != null ? x.dns : null)
      dscp                                 = (try(x.dscp, null) != null ? x.dscp : null)
      packet_length                        = (try(x.packet_length, null) != null ? x.packet_length : null)
      plp                                  = (try(x.plp, null) != null ? x.plp : null)
      protocol                             = (try(x.protocols, null) != null ? x.protocols[0] : null) // should be supporting multiple protocols, but not documented in Provider itself
      source_data_prefix_list_id           = (try(x.source_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.source_data_prefix_list].id : null)
      source_data_prefix_list_version      = (try(x.source_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.source_data_prefix_list].version : null)
      source_ip                            = (try(x.source_data_prefix, null) != null ? x.source_data_prefix : null)
      source_port                          = (try(x.source_ports, null) != null ? x.source_ports[0] : null) // should be supporting multiple ports, but not documented in Provider itself
      destination_data_prefix_list_id      = (try(x.destination_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.destination_data_prefix_list].id : null)
      destination_data_prefix_list_version = (try(x.destination_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.destination_data_prefix_list].version : null)
      destination_ip                       = (try(x.destination_data_prefix, null) != null ? x.destination_data_prefix : null)
      destination_region                   = (try(x.destination_region, null) != null ? x.destination_region : null)
      destination_port                     = (try(x.destination_ports, null) != null ? x.destination_ports[0] : null) // should be supporting multiple ports, but not documented in Provider itself
      tcp                                  = (try(x.tcp, null) != null ? x.tcp : null)
      traffic_to                           = (try(x.traffic_to, null) != null ? x.traffic_to : null)
    }] : null
    action_entries = try(s.actions, null) != null ? concat(
      (try(s.actions, null) != null ? [for y in s.actions : {
        type = (
          try(y.cflowd, null) != null ? "cflowd" :
          try(y.counter_name, null) != null ? "count" :
          try(y.dre_optimization, null) != null ? "dreOptimization" :
          try(y.fallback_to_routing, null) != null ? "fallbackToRouting" :
          try(y.log, null) == "enabled" ? "log" :
          try(y.nat_vpn, null) != null ? "nat" :
          try(y.nat_pool, null) != null ? "nat" :
          try(y.redirect_dns_type, null) != null ? "redirectDns" :
          try(y.service_node_group, null) != null ? "serviceNodeGroup" :
          try(y.set_parameters, null) != null ? "set" :
          try(y.sig, null) != null ? "sig" :
          null
        )
        counter                       = try(y.counter_name, null) != null ? y.counter_name : null
        log                           = try(y.log, null) == "enabled" ? true : null
        loss_correction               = try(y.loss_correction, null) != null ? y.loss_correction : null
        loss_correction_fec           = try(y.loss_correction, null) != null ? y.loss_correction : null
        loss_correction_fec_threshold = try(y.loss_correction, null) != null ? y.loss_threshold_percentage : null
        secure_internet_gateway       = try(y.sig, null) == "enabled" ? true : null
        redirect_dns = (
          try(y.redirect_dns_type, null) == "host" ? "dnsType" :
          try(y.redirect_dns_type, null) == "umbrella" ? "dnsType" :
          try(y.redirect_dns_type, null) == "ipAddress" ? "ipAddress" : null
        )
        redirect_dns_type = (
          try(y.redirect_dns_type, null) == "host" ? "host" :
          try(y.redirect_dns_type, null) == "umbrella" ? "umbrella" : null
          # try(y.redirect_dns_ip_address, null) != null ? y.redirect_dns_ip_address : null
        )
        redirect_dns_address = (
          try(y.redirect_dns_type, null) == "host" ? "host" :
          try(y.redirect_dns_type, null) == "umbrella" ? "umbrella" :
          try(y.redirect_dns_ip_address, null) != null ? y.redirect_dns_ip_address : null
        )
        nat_parameters = (
          try(y.nat_vpn, null) != null ? [for h in keys(y) : {
            type = (
              h == "nat_vpn" ? "useVpn" :
              h == "nat_vpn_fallback" ? "fallback" : null
            )
            vpn_id = (
              h == "nat_vpn" ? y.nat_vpn : null
            )
            fallback = (
              h == "nat_vpn_fallback" ? y.nat_vpn_fallback : null
            )
          }] :
          try(y.nat_pool, null) != null ? [{
            type        = "pool"
            nat_pool_id = y.nat_pool
        }] : null)
        set_parameters = try(y.set_parameters, null) != null ? [for z in try(y.set_parameters, null) : {
          type = (
            try(z.dscp, null) != null ? "dscp" :
            try(z.forwarding_class, null) != null ? "forwardingClass" :
            try(z.policer_list, null) != null ? "policer" :
            try(z.service, null) != null ? "service" :
            try(z.tloc_list, null) != null ? "tlocList" :
            try(z.tloc, null) != null ? "tloc" :
            try(z.vpn, null) != null ? "vpn" :
            try(z.local_tloc_list, null) != null ? "localTlocList" :
            try(z.next_hop, null) != null ? "nextHop" :
            try(z.when_next_hop_is_not_available, null) != null ? "nextHopLoose" :
            try(z.preferred_color_group, null) != null ? "preferredColorGroup" :
            null
          )
          dscp                       = try(z.dscp, null) != null ? z.dscp : null
          forwarding_class           = try(z.forwarding_class, null) != null ? z.forwarding_class : null
          policer_list_id            = try(z.policer_list, null) != null ? sdwan_policer_policy_object.policer_policy_object[z.policer_list].id : null
          policer_list_version       = try(z.policer_list, null) != null ? sdwan_policer_policy_object.policer_policy_object[z.policer_list].version : null
          service_type               = try(z.service.type, null) != null ? z.service.type : null
          service_vpn_id             = try(z.service.vpn, null) != null ? z.service.vpn : null
          service_tloc_list_id       = try(z.service.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.service.tloc_list].id : null
          service_tloc_list_version  = try(z.service.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.service.tloc_list].version : null
          service_tloc_ip            = try(z.service.tloc.ip, null) != null ? z.service.tloc.ip : null
          service_tloc_color         = try(z.service.tloc.color, null) != null ? z.service.tloc.color : null
          service_tloc_encapsulation = try(z.service.tloc.encap, null) != null ? z.service.tloc.encap : null
          tloc_list_id               = try(z.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.tloc_list].id : null
          tloc_list_version          = try(z.tloc_list, null) != null ? sdwan_tloc_list_policy_object.tloc_list_policy_object[z.tloc_list].version : null
          tloc_ip                    = try(z.tloc.ip, null) != null ? z.tloc.ip : null
          tloc_color                 = try(z.tloc.color, null) != null ? z.tloc.color : null
          tloc_encapsulation         = try(z.tloc.encap, null) != null ? z.tloc.encap : null
          vpn_id                     = try(z.vpn, null) != null ? z.vpn : null
          local_tloc_list_color      = try(z.local_tloc_list.colors, null) != null ? z.local_tloc_list.colors[0] : null
          local_tloc_list_encap      = try(z.local_tloc_list.encaps, null) != null ? z.local_tloc_list.encaps[0] : null
          local_tloc_list_restrict   = try(z.local_tloc_list.restrict, null) == "restrict" ? true : null
          next_hop                   = try(z.next_hop, null) != null ? z.next_hop : null
          next_hop_loose             = try(z.when_next_hop_is_not_available, null) == "route_table_entry" ? true : null
          #            preferred_color_group_list >> pending module support
          #            preferred_color_group_list_version >> pending module support
        }] : null
        }
        if try(!contains(["fecAdaptive", "fecAlways", "packetDuplication"], try(y.loss_correction, [])))
        && try(!contains([true, false], try(y.appqoe_optimization_tcp, [])))
      && try(!contains([true, false], try(y.appqoe_optimization_dre, [])))] : null),
      (try(s.actions, null) != null ? [for v in s.actions : {
        type            = "lossProtect"
        loss_correction = v.loss_correction
      } if try(v.loss_correction, null) != null] : null),
      (try(s.actions, null) != null ? [for w in s.actions : {
        type                          = "lossProtectFec"
        loss_correction_fec           = w.loss_correction
        loss_correction_fec_threshold = w.loss_threshold_percentage
      } if try(w.loss_threshold_percentage, null) != null] : null),
      (try(s.actions, null) != null ? [for a in s.actions : {
        type             = "tcpOptimization"
        tcp_optimization = a.appqoe_optimization_tcp
      } if try(a.appqoe_optimization_tcp, null) == true] : null),
      (try(s.actions, null) != null ? [for b in s.actions : {
        type             = "dreOptimization"
        dre_optimization = b.appqoe_optimization_dre
      } if try(b.appqoe_optimization_dre, null) == true] : null)
    ) : null
  }]
}

resource "sdwan_cflowd_policy_definition" "cflowd_policy_definition" {
  for_each              = { for d in try(local.centralized_policies.definitions.data_policy.cflowd, {}) : d.name => d }
  name                  = each.value.name
  description           = each.value.description
  active_flow_timeout   = each.value.active_flow_timeout
  inactive_flow_timeout = each.value.inactive_flow_timeout
  sampling_interval     = each.value.sampling_interval
  flow_refresh          = each.value.flow_refresh
  protocol              = each.value.protocol
  tos                   = each.value.tos
  remarked_dscp         = each.value.remarked_dscp
  collectors = try(length(each.value.collectors) == 0, true) ? null : [for t in each.value.collectors : {
    vpn_id           = t.vpn
    ip_address       = t.ip_address
    port             = t.port
    transport        = t.transport
    source_interface = t.source_interface
    export_spreading = t.export_spreading
  }]
}

resource "sdwan_application_aware_routing_policy_definition" "application_aware_routing_policy_definition" {
  for_each    = { for d in try(local.centralized_policies.definitions.data_policy.application_aware_routing, {}) : d.name => d }
  name        = each.value.name
  description = each.value.description
  # default_action = try(each.value.default_action_type, null) // not available in provider but available in GUI
  sequences = [for s in each.value.sequences : {
    id      = s.id
    name    = s.name
    ip_type = try(s.ip_type, null)
    match_entries = try(s.match_criterias, null) != null ? [for x in s.match_criterias : {
      type = (
        try(x.application_list, null) != null ? "appList" :
        #        try(x.cloud_saas_application_list, null) != null ? "cloudSaasAppList" :
        try(x.dns_application_list, null) != null ? "dnsAppList" :
        try(x.dns, null) != null ? "dns" :
        try(x.dscp, null) != null ? "dscp" :
        try(x.plp, null) != null ? "plp" :
        try(x.protocols, null) != null ? "protocol" :
        try(x.source_data_prefix_list, null) != null ? "sourceDataPrefixList" :
        try(x.source_data_prefix, null) != null ? "sourceIp" :
        try(x.source_ports, null) != null ? "sourcePort" :
        try(x.destination_data_prefix_list, null) != null ? "destinationDataPrefixList" :
        try(x.destination_data_prefix, null) != null ? "destinationIp" :
        try(x.destination_region, null) != null ? "destinationRegion" :
        try(x.destination_ports, null) != null ? "destinationPort" :
        try(x.traffic_to, null) != null ? "trafficTo" :
        null
      )
      application_list_id      = (try(x.application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.application_list].id : null)
      application_list_version = (try(x.application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.application_list].version : null)
      #        cloud_saas_application_list_id = (try(x.cloud_saas_application_list, null) != null ? sdwan_cloud_saas_application_list_policy_object.cloud_saas_application_list_policy_object[x.cloud_saas_application_list].id : null)
      #        cloud_saas_application_list_version = (try(x.cloud_saas_application_list, null) != null ? sdwan_cloud_saas_application_list_policy_object.cloud_saas_application_list_policy_object[x.cloud_saas_application_list].version : null)
      dns_application_list_id              = (try(x.dns_application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.dns_application_list].id : null)
      dns_application_list_version         = (try(x.dns_application_list, null) != null ? sdwan_application_list_policy_object.application_list_policy_object[x.dns_application_list].version : null)
      dns                                  = (try(x.dns, null) != null ? x.dns : null)
      dscp                                 = (try(x.dscp, null) != null ? x.dscp : null)
      plp                                  = (try(x.plp, null) != null ? x.plp : null)
      protocol                             = (try(x.protocols, null) != null ? x.protocols[0] : null) # Provider allows only one protocol to be defined
      source_data_prefix_list_id           = (try(x.source_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.source_data_prefix_list].id : null)
      source_data_prefix_list_version      = (try(x.source_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.source_data_prefix_list].version : null)
      source_ip                            = (try(x.source_data_prefix, null) != null ? x.source_data_prefix : null)
      source_port                          = (try(x.source_ports, null) != null ? x.source_ports[0] : null) # Provider allows only one port to be defined
      destination_data_prefix_list_id      = (try(x.destination_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.destination_data_prefix_list].id : null)
      destination_data_prefix_list_version = (try(x.destination_data_prefix_list, null) != null ? sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[x.destination_data_prefix_list].version : null)
      destination_ip                       = (try(x.destination_data_prefix, null) != null ? x.destination_data_prefix : null)
      destination_region                   = (try(x.destination_region, null) != null ? x.destination_region : null)
      destination_port                     = (try(x.destination_ports, null) != null ? x.destination_ports[0] : null) # Provider allows only one port to be defined
      traffic_to                           = (try(x.traffic_to, null) != null ? x.traffic_to : null)
    }] : null
    action_entries = (try(s.actions, null) != null ? [for y in s.actions : {
      type = (
        try(y.backup_sla_preferred_color, null) != null ? "backupSlaPreferredColor" :
        try(y.counter_name, null) != null ? "count" :
        try(y.log, null) != null ? "log" :
        try(y.sla_class_list_name, null) != null ? "slaClass" :
        try(y.cloud_sla, null) != null ? "cloudSaas" :
        null
      )
      backup_sla_preferred_color = try(y.backup_sla_preferred_color, null) != null ? y.backup_sla_preferred_color : null
      counter                    = try(y.counter_name, null) != null ? y.counter_name : null
      log                        = try(y.log, null) == "enabled" ? true : null
      sla_class_parameters = try(y.sla_class_list_name, null) != null ? [{
        type                   = try(y.sla_class_list_name, null) != null ? "name" : null
        sla_class_list         = try(y.sla_class_list_name, null) != null ? sdwan_sla_class_policy_object.sla_class_policy_object[y.sla_class_list_name].id : null
        sla_class_list_version = try(y.sla_class_list_name, null) != null ? sdwan_sla_class_policy_object.sla_class_policy_object[y.sla_class_list_name].version : null
        },
        {
          type            = try(y.sla_class_list_preferred_color, null) != null ? "preferredColor" : null
          preferred_color = try(y.sla_class_list_preferred_color, null) != null ? y.sla_class_list_preferred_color : null
        }
        #        {
        #        type = try(y.sla_class_list_preferred_color_group, null) != null ? "preferredColorGroup" : null
        #        preferred_color_group_list = try(y.sla_class_list_preferred_color_group, null) != null ? y.sla_class_list_preferred_color_group : null
        #        }
      ] : null
      cloud_sla = try(y.cloud_sla, null) == "enabled" ? true : null
  }] : null) }]
}