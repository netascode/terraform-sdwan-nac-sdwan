resource "sdwan_activate_centralized_policy" "activate_centralized_policy" {
  for_each = { for p in keys(try(local.centralized_policies, {})) : p => p
  if p == "activated_policy" }
  id      = try(local.centralized_policies.activated_policy, null) != null ? sdwan_centralized_policy.centralized_policy[local.centralized_policies.activated_policy].id : null
  version = try(local.centralized_policies.activated_policy, null) != null ? sdwan_centralized_policy.centralized_policy[local.centralized_policies.activated_policy].version : null

  depends_on = [sdwan_attach_feature_device_template.attach_feature_device_template]
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
      entries = [for h in keys(try(d.site_region, [])) : {
        direction = (
          h == "site_lists_in" ? "in" :
          h == "site_lists_out" ? "out" :
          h == "region_lists_in" ? "in" :
          h == "region_lists_out" ? "out" :
          h == "region_in" ? "in" :
          h == "region_out" ? "out" :
          null
        )
        site_list_ids = (
          h == "site_lists_in" ? [for x in try(d.site_region.site_lists_in, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] :
          h == "site_lists_out" ? [for x in try(d.site_region.site_lists_out, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] :
          null
        )
        site_list_versions = (
          h == "site_lists_in" ? [for x in try(d.site_region.site_lists_in, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] :
          h == "site_lists_out" ? [for x in try(d.site_region.site_lists_out, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] :
          null
        )
        region_list_ids = (
          h == "region_lists_in" ? [for x in try(d.site_region.region_lists_in, []) : sdwan_region_list_policy_object.region_list_policy_object[x].id] :
          h == "region_lists_out" ? [for x in try(d.site_region.region_lists_out, []) : sdwan_region_list_policy_object.region_list_policy_object[x].id] :
          null
        )
        region_list_versions = (
          h == "region_lists_in" ? [for x in try(d.site_region.region_lists_in, []) : sdwan_region_list_policy_object.region_list_policy_object[x].version] :
          h == "region_lists_out" ? [for x in try(d.site_region.region_lists_out, []) : sdwan_region_list_policy_object.region_list_policy_object[x].version] :
          null
        )
        region_ids = (
          h == "region_in" ? try([d.site_region.region_in], []) :
          h == "region_out" ? try([d.site_region.region_out], []) :
          null
        )
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
        direction            = try(h.direction, null) != null ? h.direction : null
        site_list_ids        = try(h.site_lists, null) != null ? [for x in try(h.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] : null
        site_list_versions   = try(h.site_lists, null) != null ? [for x in try(h.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] : null
        vpn_list_ids         = try(h.vpn_lists, null) != null ? [for x in try(h.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].id] : null
        vpn_list_versions    = try(h.vpn_lists, null) != null ? [for x in try(h.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].version] : null
        region_list_ids      = try(h.region_list, null) != null ? [sdwan_region_list_policy_object.region_list_policy_object[h.region_list].id] : null
        region_list_versions = try(h.region_list, null) != null ? [sdwan_region_list_policy_object.region_list_policy_object[h.region_list].version] : null
        region_ids           = try(h.region, null) != null ? [h.region] : null
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
        site_list_ids        = try(d.site_region_vpn.site_lists, null) != null ? [for x in try(d.site_region_vpn.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].id] : null
        site_list_versions   = try(d.site_region_vpn.site_lists, null) != null ? [for x in try(d.site_region_vpn.site_lists, []) : sdwan_site_list_policy_object.site_list_policy_object[x].version] : null
        vpn_list_ids         = try(d.site_region_vpn.vpn_lists, null) != null ? [for x in try(d.site_region_vpn.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].id] : null
        vpn_list_versions    = try(d.site_region_vpn.vpn_lists, null) != null ? [for x in try(d.site_region_vpn.vpn_lists, []) : sdwan_vpn_list_policy_object.vpn_list_policy_object[x].version] : null
        region_list_ids      = try(d.site_region_vpn.region_list, null) != null ? [sdwan_region_list_policy_object.region_list_policy_object[d.site_region_vpn.region_list].id] : null
        region_list_versions = try(d.site_region_vpn.region_list, null) != null ? [sdwan_region_list_policy_object.region_list_policy_object[d.site_region_vpn.region_list].version] : null
        region_ids           = try(d.site_region_vpn.region, null) != null ? [d.site_region_vpn.region] : null
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
    ip_type     = try(s.ip_type, local.defaults.sdwan.centralized_policies.definitions.control_policy.custom_control_topology.sequences.ip_type)
    base_action = try(s.base_action, null)
    match_entries = try(s.match_criterias, null) == null ? null : flatten([
      try(s.match_criterias.color_list, null) == null ? [] : [{
        type               = "colorList"
        color_list_id      = sdwan_color_list_policy_object.color_list_policy_object[s.match_criterias.color_list].id
        color_list_version = sdwan_color_list_policy_object.color_list_policy_object[s.match_criterias.color_list].version
      }],
      try(s.match_criterias.community_list, null) == null ? [] : [{
        type                   = "community"
        community_list_id      = sdwan_standard_community_list_policy_object.standard_community_list_policy_object[s.match_criterias.community_list].id
        community_list_version = sdwan_standard_community_list_policy_object.standard_community_list_policy_object[s.match_criterias.community_list].version
      }],
      try(s.match_criterias.omp_tag, null) == null ? [] : [{
        type    = "ompTag"
        omp_tag = s.match_criterias.omp_tag
      }],
      try(s.match_criterias.expanded_community_list, null) == null ? [] : [{
        type                            = "expandedCommunity"
        expanded_community_list_id      = sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[s.match_criterias.expanded_community_list].id
        expanded_community_list_version = sdwan_expanded_community_list_policy_object.expanded_community_list_policy_object[s.match_criterias.expanded_community_list].version
      }],
      try(s.match_criterias.origin, null) == null ? [] : [{
        type   = "origin"
        origin = s.match_criterias.origin
      }],
      try(s.match_criterias.originator, null) == null ? [] : [{
        type       = "originator"
        originator = s.match_criterias.originator
      }],
      try(s.match_criterias.preference, null) == null ? [] : [{
        type       = "preference"
        preference = s.match_criterias.preference
      }],
      try(s.match_criterias.site_list, null) == null ? [] : [{
        type              = "siteList"
        site_list_id      = sdwan_site_list_policy_object.site_list_policy_object[s.match_criterias.site_list].id
        site_list_version = sdwan_site_list_policy_object.site_list_policy_object[s.match_criterias.site_list].version
      }],
      try(s.match_criterias.site_id, null) == null ? [] : [{
        type    = "siteId"
        site_id = s.match_criterias.site_id
      }],
      try(s.match_criterias.path_type, null) == null ? [] : [{
        type      = "pathType"
        path_type = s.match_criterias.path_type
      }],
      try(s.match_criterias.tloc_list, null) == null ? [] : [{
        type              = "tlocList"
        tloc_list_id      = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.match_criterias.tloc_list].id
        tloc_list_version = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.match_criterias.tloc_list].version
      }],
      try(s.match_criterias.tloc, null) == null ? [] : [{
        type               = "tloc"
        tloc_ip            = s.match_criterias.tloc.ip
        tloc_color         = s.match_criterias.tloc.color
        tloc_encapsulation = s.match_criterias.tloc.encap
      }],
      try(s.match_criterias.vpn_list, null) == null ? [] : [{
        type             = "vpnList"
        vpn_list_id      = sdwan_vpn_list_policy_object.vpn_list_policy_object[s.match_criterias.vpn_list].id
        vpn_list_version = sdwan_vpn_list_policy_object.vpn_list_policy_object[s.match_criterias.vpn_list].version
      }],
      try(s.match_criterias.vpn, null) == null ? [] : [{
        type   = "vpn"
        vpn_id = s.match_criterias.vpn
      }],
      try(s.match_criterias.ipv4_prefix_list, null) == null ? [] : [{
        type                = "prefixList"
        prefix_list_id      = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.ipv4_prefix_list].id
        prefix_list_version = sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[s.match_criterias.ipv4_prefix_list].version
      }],
      try(s.match_criterias.carrier, null) == null ? [] : [{
        type    = "carrier"
        carrier = s.match_criterias.carrier
      }],
      try(s.match_criterias.domain_id, null) == null ? [] : [{
        type      = "domainId"
        domain_id = s.match_criterias.domain_id
      }],
      try(s.match_criterias.group_id, null) == null ? [] : [{
        type     = "groupId"
        group_id = s.match_criterias.group_id
      }],
      try(s.match_criterias.region_id, null) == null ? [] : [{
        type      = "regionId"
        region_id = s.match_criterias.region_id
      }],
      try(s.match_criterias.role, null) == null ? [] : [{
        type = "role"
        role = s.match_criterias.role
      }]
    ])
    action_entries = try(s.actions, null) == null ? null : flatten([
      try(s.actions.community, null) == null && try(s.actions.community_additive, null) == null && try(s.actions.omp_tag, null) == null && try(s.actions.preference, null) == null && try(s.actions.tloc_action, null) == null && try(s.actions.tloc, null) == null && try(s.actions.tloc_list, null) == null ? [] : [{
        type = "set"
        set_parameters = flatten([
          try(s.actions.community, null) == null ? [] : [{
            type      = "community"
            community = s.actions.community
          }],
          try(s.actions.community_additive, null) == null ? [] : [{
            type               = "communityAdditive"
            community_additive = s.actions.community_additive
          }],
          try(s.actions.omp_tag, null) == null ? [] : [{
            type    = "ompTag"
            omp_tag = s.actions.omp_tag
          }],
          try(s.actions.preference, null) == null ? [] : [{
            type       = "preference"
            preference = s.actions.preference
          }],
          try(s.actions.tloc_action, null) == null ? [] : [{
            type        = "tlocAction"
            tloc_action = s.actions.tloc_action
          }],
          try(s.actions.tloc, null) == null ? [] : [{
            type               = "tloc"
            tloc_ip            = s.actions.tloc.ip
            tloc_color         = s.actions.tloc.color
            tloc_encapsulation = s.actions.tloc.encap
          }],
          try(s.actions.tloc_list, null) == null ? [] : [{
            type              = "tlocList"
            tloc_list_id      = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.tloc_list].id
            tloc_list_version = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.tloc_list].version
          }],
          try(s.actions.service, null) == null ? [] : [{
            type                       = "service"
            service_type               = try(s.actions.service.type, null) == null ? null : s.actions.service.type
            service_vpn_id             = try(s.actions.service.vpn, null) == null ? null : s.actions.service.vpn
            service_tloc_list_id       = try(s.actions.service.tloc_list, null) == null ? null : sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.service.tloc_list].id
            service_tloc_list_version  = try(s.actions.service.tloc_list, null) == null ? null : sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.service.tloc_list].version
            service_tloc_ip            = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.ip
            service_tloc_color         = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.color
            service_tloc_encapsulation = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.encap
          }]
        ])
      }],
      try(s.actions.export_to_vpn_list, null) == null ? [] : [{
        type                       = "exportTo"
        export_to_vpn_list_id      = sdwan_vpn_list_policy_object.vpn_list_policy_object[s.actions.export_to_vpn_list].id
        export_to_vpn_list_version = sdwan_vpn_list_policy_object.vpn_list_policy_object[s.actions.export_to_vpn_list].version
      }]
    ])
  }]
}

resource "sdwan_hub_and_spoke_topology_policy_definition" "hub_and_spoke_topology_policy_definition" {
  for_each         = { for d in try(local.centralized_policies.definitions.control_policy.hub_and_spoke_topology, {}) : d.name => d }
  name             = each.value.name
  description      = each.value.description
  vpn_list_id      = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].id
  vpn_list_version = sdwan_vpn_list_policy_object.vpn_list_policy_object[each.value.vpn_list].version
  topologies = try(length(each.value.hub_and_spoke_sites) == 0, true) ? null : [for t in each.value.hub_and_spoke_sites : {
    name                = t.name
    all_hubs_are_equal  = try(t.equal_preference, null)
    advertise_hub_tlocs = try(t.advertise_tloc, null)
    tloc_list_id        = try(t.tloc_list, null) == null ? null : sdwan_tloc_list_policy_object.tloc_list_policy_object[t.tloc_list].id
    spokes = try(length(t.spokes) == 0, true) ? null : [for s in t.spokes : {
      site_list_id      = sdwan_site_list_policy_object.site_list_policy_object[s.site_list].id
      site_list_version = sdwan_site_list_policy_object.site_list_policy_object[s.site_list].version
      hubs = try(length(s.hubs) == 0, true) ? null : [for h in s.hubs : {
        site_list_id         = sdwan_site_list_policy_object.site_list_policy_object[h.site_list].id
        site_list_version    = sdwan_site_list_policy_object.site_list_policy_object[h.site_list].version
        ipv4_prefix_list_ids = try(length(h.ipv4_prefix_lists) == 0, true) ? null : [for p in h.ipv4_prefix_lists : sdwan_ipv4_prefix_list_policy_object.ipv4_prefix_list_policy_object[p].id]
        ipv6_prefix_list_ids = try(length(h.ipv6_prefix_lists) == 0, true) ? null : [for p in h.ipv6_prefix_lists : sdwan_ipv6_prefix_list_policy_object.ipv6_prefix_list_policy_object[p].id]
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
      try(s.type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.type) == "application_firewall" ? "applicationFirewall" :
      try(s.type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.type) == "qos" ? "qos" :
      try(s.type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.type) == "service_chaining" ? "serviceChaining" :
      try(s.type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.type) == "traffic_engineering" ? "trafficEngineering" :
      try(s.type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.type) == "custom" ? "data" :
      null
    )
    ip_type     = try(s.ip_type, local.defaults.sdwan.centralized_policies.definitions.data_policy.traffic_data.sequences.ip_type)
    base_action = try(s.base_action, null)
    match_entries = try(s.match_criterias, null) == null ? null : flatten([
      try(s.match_criterias.application_list, null) == null ? [] : [{
        type                     = "appList"
        application_list_id      = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.application_list].id
        application_list_version = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.application_list].version
      }],
      try(s.match_criterias.dns_application_list, null) == null ? [] : [{
        type                         = "dnsAppList"
        dns_application_list_id      = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.dns_application_list].id
        dns_application_list_version = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.dns_application_list].version
      }],
      try(s.match_criterias.dns, null) == null ? [] : [{
        type = "dns"
        dns  = s.match_criterias.dns
      }],
      try(s.match_criterias.dscp, null) == null ? [] : [{
        type = "dscp"
        dscp = s.match_criterias.dscp
      }],
      try(s.match_criterias.packet_length, null) == null ? [] : [{
        type          = "packetLength"
        packet_length = s.match_criterias.packet_length
      }],
      try(s.match_criterias.plp, null) == null ? [] : [{
        type = "plp"
        plp  = s.match_criterias.plp
      }],
      try(s.match_criterias.protocols, null) == null && try(s.match_criterias.protocol_ranges, null) == null ? [] : [{
        type     = "protocol"
        protocol = join(" ", concat([for p in try(s.match_criterias.protocols, []) : p], [for r in try(s.match_criterias.protocol_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                            = "sourceDataPrefixList"
        source_data_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_data_prefix, null) == null ? [] : [{
        type      = "sourceIp"
        source_ip = s.match_criterias.source_data_prefix
      }],
      try(s.match_criterias.source_ports, null) == null && try(s.match_criterias.source_port_ranges, null) == null ? [] : [{
        type        = "sourcePort"
        source_port = join(" ", concat([for p in try(s.match_criterias.source_ports, []) : p], [for r in try(s.match_criterias.source_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                 = "destinationDataPrefixList"
        destination_data_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_data_prefix, null) == null ? [] : [{
        type           = "destinationIp"
        destination_ip = s.match_criterias.destination_data_prefix
      }],
      try(s.match_criterias.destination_region, null) == null ? [] : [{
        type               = "destinationRegion"
        destination_region = s.match_criterias.destination_region
      }],
      try(s.match_criterias.destination_ports, null) == null && try(s.match_criterias.destination_port_ranges, null) == null ? [] : [{
        type             = "destinationPort"
        destination_port = join(" ", concat([for p in try(s.match_criterias.destination_ports, []) : p], [for r in try(s.match_criterias.destination_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.tcp, null) == null ? [] : [{
        type = "tcp"
        tcp  = s.match_criterias.tcp
      }],
      try(s.match_criterias.traffic_to, null) == null ? [] : [{
        type       = "trafficTo"
        traffic_to = s.match_criterias.traffic_to
      }]
    ])
    action_entries = try(s.actions, null) == null ? null : flatten([
      try(s.actions.log, null) == null ? [] : [{
        type = "log"
        log  = s.actions.log
      }],
      try(s.actions.cflowd, null) == null ? [] : [{
        type   = "cflowd"
        cflowd = s.actions.cflowd
      }],
      try(s.actions.counter_name, null) == null ? [] : [{
        type    = "count"
        counter = s.actions.counter_name
      }],
      try(s.actions.appqoe_optimization.tcp, null) == null ? [] : [{
        type             = "tcpOptimization"
        tcp_optimization = s.actions.appqoe_optimization.tcp
      }],
      try(s.actions.appqoe_optimization.dre, null) == null ? [] : [{
        type             = "dreOptimization"
        dre_optimization = s.actions.appqoe_optimization.dre
      }],
      try(s.actions.appqoe_optimization.service_node_group, null) == null ? [] : [{
        type               = "serviceNodeGroup"
        service_node_group = s.actions.appqoe_optimization.service_node_group
      }],
      try(s.actions.sig.enabled, null) == null ? [] : [{
        type                    = "sig"
        secure_internet_gateway = s.actions.sig.enabled
      }],
      try(s.actions.sig.enabled, false) == false ? [] : try(s.actions.sig.fallback_to_routing, false) == false ? [] : [{
        type                = "fallbackToRouting"
        fallback_to_routing = s.actions.sig.fallback_to_routing
      }],
      try(s.actions.loss_correction.type, null) == null ? [] : [{
        type            = "lossProtect"
        loss_correction = s.actions.loss_correction.type
      }],
      try(s.actions.loss_correction.type, null) == "fecAdaptive" ? [{
        type                          = "lossProtectFec"
        loss_correction_fec           = s.actions.loss_correction.type
        loss_correction_fec_threshold = try(s.actions.loss_correction.loss_threshold_percentage, null)
      }] : [],
      try(s.actions.loss_correction.type, null) == "packetDuplication" ? [{
        type                               = "lossProtectPktDup"
        loss_correction_packet_duplication = s.actions.loss_correction.type
      }] : [],
      try(s.actions.loss_correction.type, null) == "fecAlways" ? [{
        type                = "lossProtectFec"
        loss_correction_fec = s.actions.loss_correction.type
      }] : [],
      try(s.actions.redirect_dns.type, null) == null ? [] : [{
        type = "redirectDns"
        redirect_dns = (
          try(s.actions.redirect_dns.type, null) == "host" ? "dnsType" :
          try(s.actions.redirect_dns.type, null) == "umbrella" ? "dnsType" :
          try(s.actions.redirect_dns.type, null) == "ipAddress" ? "ipAddress" :
          null
        )
        redirect_dns_type = (
          try(s.actions.redirect_dns.type, null) == "host" ? s.actions.redirect_dns.type :
          try(s.actions.redirect_dns.type, null) == "umbrella" ? s.actions.redirect_dns.type :
          null
        )
        redirect_dns_address = (
          try(s.actions.redirect_dns.type, null) == "ipAddress" ? try(s.actions.redirect_dns.ip_address, null) :
          null
        )
      }],
      try(s.actions.nat_vpn, null) == null ? [] : [{
        type = "nat"
        nat_parameters = flatten([
          try(s.actions.nat_vpn.vpn_id, null) == null ? [] : [{
            type   = "useVpn"
            vpn_id = s.actions.nat_vpn.vpn_id
          }],
          try(s.actions.nat_vpn.vpn_id, null) == null ? [] : [{
            type     = "fallback"
            fallback = try(s.actions.nat_vpn.nat_vpn_fallback, false)
          }]
        ])
      }],
      try(s.actions.nat_pool, null) == null ? [] : [{
        type        = "nat"
        nat_pool    = "pool"
        nat_pool_id = s.actions.nat_pool
      }],
      try(s.actions.dscp, null) == null && try(s.actions.forwarding_class, null) == null && try(s.actions.policer_list, null) == null && try(s.actions.service, null) == null && try(s.actions.tloc_list, null) == null && try(s.actions.tloc, null) == null && try(s.actions.vpn, null) == null && try(s.actions.local_tloc_list, null) == null && try(s.actions.next_hop, null) == null && try(s.actions.preferred_color_group, null) == null ? [] : [{
        type = "set"
        set_parameters = flatten([
          try(s.actions.dscp, null) == null ? [] : [{
            type = "dscp"
            dscp = s.actions.dscp
          }],
          try(s.actions.forwarding_class, null) == null ? [] : [{
            type             = "forwardingClass"
            forwarding_class = s.actions.forwarding_class
          }],
          try(s.actions.policer_list, null) == null ? [] : [{
            type                 = "policer"
            policer_list_id      = sdwan_policer_policy_object.policer_policy_object[s.actions.policer_list].id
            policer_list_version = sdwan_policer_policy_object.policer_policy_object[s.actions.policer_list].version
          }],
          try(s.actions.service, null) == null ? [] : [{
            type                       = "service"
            service_type               = try(s.actions.service.type, null) == null ? null : s.actions.service.type
            service_vpn_id             = try(s.actions.service.vpn, null) == null ? null : s.actions.service.vpn
            service_tloc_list_id       = try(s.actions.service.tloc_list, null) == null ? null : sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.service.tloc_list].id
            service_tloc_list_version  = try(s.actions.service.tloc_list, null) == null ? null : sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.service.tloc_list].version
            service_tloc_ip            = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.ip
            service_tloc_color         = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.color
            service_tloc_encapsulation = try(s.actions.service.tloc, null) == null ? null : s.actions.service.tloc.encap
            service_tloc_local         = try(s.actions.service.local, null) == null ? null : s.actions.service.local
            service_tloc_restrict      = try(s.actions.service.restrict, null) == null ? null : s.actions.service.restrict
          }],
          try(s.actions.tloc_list, null) == null ? [] : [{
            type              = "tlocList"
            tloc_list_id      = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.tloc_list].id
            tloc_list_version = sdwan_tloc_list_policy_object.tloc_list_policy_object[s.actions.tloc_list].version
          }],
          try(s.actions.tloc, null) == null ? [] : [{
            type               = "tloc"
            tloc_ip            = s.actions.tloc.ip
            tloc_color         = s.actions.tloc.color
            tloc_encapsulation = s.actions.tloc.encap
          }],
          try(s.actions.vpn, null) == null ? [] : [{
            type   = "vpn"
            vpn_id = s.actions.vpn
          }],
          try(s.actions.local_tloc_list, null) == null ? [] : [{
            type                     = "localTlocList"
            local_tloc_list_color    = join(" ", concat([for p in try(s.actions.local_tloc_list.colors, []) : p]))
            local_tloc_list_encap    = length(join(" ", concat([for p in try(s.actions.local_tloc_list.encaps, []) : p]))) > 0 ? join(" ", concat([for p in try(s.actions.local_tloc_list.encaps, []) : p])) : null
            local_tloc_list_restrict = try(s.actions.local_tloc_list.restrict, null) == null ? null : s.actions.local_tloc_list.restrict
          }],
          try(s.actions.next_hop.ip_address, null) == null ? [] : [{
            type     = "nextHop"
            next_hop = try(s.actions.next_hop.ip_address, null) == null ? null : s.actions.next_hop.ip_address
          }],
          try(s.actions.next_hop.when_next_hop_is_not_available, null) == null ? [] : [{
            type           = "nextHopLoose"
            next_hop_loose = try(s.actions.next_hop.when_next_hop_is_not_available, null) == "route_table_entry" ? true : null
          }],
          try(s.actions.preferred_color_group, null) == null ? [] : [{
            type                               = "preferredColorGroup"
            preferred_color_group_list_id      = sdwan_preferred_color_group_policy_object.preferred_color_group_policy_object[s.actions.preferred_color_group].id
            preferred_color_group_list_version = sdwan_preferred_color_group_policy_object.preferred_color_group_policy_object[s.actions.preferred_color_group].version
          }]
        ]),
      }],
    ])
  }]
}

resource "sdwan_cflowd_policy_definition" "cflowd_policy_definition" {
  for_each              = { for d in try(local.centralized_policies.definitions.data_policy.cflowd, {}) : d.name => d }
  name                  = each.value.name
  description           = each.value.description
  active_flow_timeout   = try(each.value.active_flow_timeout, null)
  inactive_flow_timeout = try(each.value.inactive_flow_timeout, null)
  sampling_interval     = try(each.value.sampling_interval, null)
  flow_refresh          = try(each.value.flow_refresh, null)
  protocol              = try(each.value.protocol, local.defaults.sdwan.centralized_policies.definitions.data_policy.cflowd.protocol)
  tos                   = try(each.value.tos, local.defaults.sdwan.centralized_policies.definitions.data_policy.cflowd.tos)
  remarked_dscp         = try(each.value.remarked_dscp, local.defaults.sdwan.centralized_policies.definitions.data_policy.cflowd.remarked_dscp)
  collectors = try(length(each.value.collectors) == 0, true) ? null : [for t in each.value.collectors : {
    vpn_id           = t.vpn
    ip_address       = t.ip_address
    port             = t.port
    transport        = t.transport
    source_interface = t.source_interface
    export_spreading = try(t.export_spreading, null)
  }]
}

resource "sdwan_application_aware_routing_policy_definition" "application_aware_routing_policy_definition" {
  for_each       = { for d in try(local.centralized_policies.definitions.data_policy.application_aware_routing, {}) : d.name => d }
  name           = each.value.name
  description    = each.value.description
  default_action = (try(each.value.default_action_sla_class_list, null) != null ? "slaClass" : null)
  default_action_sla_class_list_id = (
    try(each.value.default_action_sla_class_list, null) != null ?
    sdwan_sla_class_policy_object.sla_class_policy_object[each.value.default_action_sla_class_list].id : null
  )
  default_action_sla_class_list_version = (
    try(each.value.default_action_sla_class_list, null) != null ?
    sdwan_sla_class_policy_object.sla_class_policy_object[each.value.default_action_sla_class_list].version : null
  )
  sequences = [for s in each.value.sequences : {
    id      = s.id
    name    = s.name
    ip_type = try(s.ip_type, local.defaults.sdwan.centralized_policies.definitions.data_policy.application_aware_routing.sequences.ip_type)
    match_entries = try(s.match_criterias, null) == null ? null : flatten([
      try(s.match_criterias.application_list, null) == null ? [] : [{
        type                     = "appList"
        application_list_id      = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.application_list].id
        application_list_version = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.application_list].version
      }],
      try(s.match_criterias.dns_application_list, null) == null ? [] : [{
        type                         = "dnsAppList"
        dns_application_list_id      = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.dns_application_list].id
        dns_application_list_version = sdwan_application_list_policy_object.application_list_policy_object[s.match_criterias.dns_application_list].version
      }],
      try(s.match_criterias.dns, null) == null ? [] : [{
        type = "dns"
        dns  = s.match_criterias.dns
      }],
      try(s.match_criterias.dscp, null) == null ? [] : [{
        type = "dscp"
        dscp = s.match_criterias.dscp
      }],
      try(s.match_criterias.plp, null) == null ? [] : [{
        type = "plp"
        plp  = s.match_criterias.plp
      }],
      try(s.match_criterias.protocols, null) == null && try(s.match_criterias.protocol_ranges, null) == null ? [] : [{
        type     = "protocol"
        protocol = join(" ", concat([for p in try(s.match_criterias.protocols, []) : p], [for r in try(s.match_criterias.protocol_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.source_data_prefix_list, null) == null ? [] : [{
        type                            = "sourceDataPrefixList"
        source_data_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].id
        source_data_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.source_data_prefix_list].version
      }],
      try(s.match_criterias.source_data_prefix, null) == null ? [] : [{
        type      = "sourceIp"
        source_ip = s.match_criterias.source_data_prefix
      }],
      try(s.match_criterias.source_ports, null) == null && try(s.match_criterias.source_port_ranges, null) == null ? [] : [{
        type        = "sourcePort"
        source_port = join(" ", concat([for p in try(s.match_criterias.source_ports, []) : p], [for r in try(s.match_criterias.source_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.destination_data_prefix_list, null) == null ? [] : [{
        type                                 = "destinationDataPrefixList"
        destination_data_prefix_list_id      = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].id
        destination_data_prefix_list_version = sdwan_data_ipv4_prefix_list_policy_object.data_ipv4_prefix_list_policy_object[s.match_criterias.destination_data_prefix_list].version
      }],
      try(s.match_criterias.destination_data_prefix, null) == null ? [] : [{
        type           = "destinationIp"
        destination_ip = s.match_criterias.destination_data_prefix
      }],
      try(s.match_criterias.destination_region, null) == null ? [] : [{
        type               = "destinationRegion"
        destination_region = s.match_criterias.destination_region
      }],
      try(s.match_criterias.destination_ports, null) == null && try(s.match_criterias.destination_port_ranges, null) == null ? [] : [{
        type             = "destinationPort"
        destination_port = join(" ", concat([for p in try(s.match_criterias.destination_ports, []) : p], [for r in try(s.match_criterias.destination_port_ranges, []) : "${r.from}-${r.to}"]))
      }],
      try(s.match_criterias.traffic_to, null) == null ? [] : [{
        type       = "trafficTo"
        traffic_to = s.match_criterias.traffic_to
      }]
    ])
    action_entries = try(s.actions, null) == null ? null : flatten([
      try(s.actions.counter_name, null) == null ? [] : [{
        type    = "count"
        counter = s.actions.counter_name
      }],
      try(s.actions.log, null) == null ? [] : [{
        type = "log"
        log  = s.actions.log
      }],
      try(s.actions.backup_sla_preferred_colors, null) == null ? [] : [{
        type                       = "backupSlaPreferredColor"
        backup_sla_preferred_color = join(" ", [for p in try(s.actions.backup_sla_preferred_colors, []) : p])
      }],
      try(s.actions.sla_class_list, null) == null ? [] : [{
        type = "slaClass"
        sla_class_parameters = flatten([
          try(s.actions.sla_class_list.sla_class_list, null) == null ? [] : [{
            type                   = "name"
            sla_class_list_id      = sdwan_sla_class_policy_object.sla_class_policy_object[s.actions.sla_class_list.sla_class_list].id
            sla_class_list_version = sdwan_sla_class_policy_object.sla_class_policy_object[s.actions.sla_class_list.sla_class_list].version
          }],
          try(s.actions.sla_class_list.preferred_colors, null) == null ? [] : [{
            type            = "preferredColor"
            preferred_color = join(" ", concat([for p in try(s.actions.sla_class_list.preferred_colors, []) : p]))
          }],
          try(s.actions.sla_class_list.preferred_color_group, null) == null ? [] : [{
            type                               = "preferredColorGroup"
            preferred_color_group_list_id      = sdwan_preferred_color_group_policy_object.preferred_color_group_policy_object[s.actions.sla_class_list.preferred_color_group].id
            preferred_color_group_list_version = sdwan_preferred_color_group_policy_object.preferred_color_group_policy_object[s.actions.sla_class_list.preferred_color_group].version
          }],
          try(s.actions.sla_class_list.when_sla_not_met, null) == "strict_drop" ? [{
            type = "strict"
          }] : [],
          try(s.actions.sla_class_list.when_sla_not_met, null) == "fallback_to_best_path" ? [{
            type = "fallbackToBestPath"
          }] : []
        ])
      }],
      try(s.actions.cloud_sla, null) == null ? [] : [{
        type      = "cloudSaas"
        cloud_sla = s.actions.cloud_sla
      }]
    ])
  }]
}
