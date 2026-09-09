locals {
  # Loop over both type names instead of duplicating this block per type.
  nh_l0_all = flatten([
    for t in ["group", "region"] : [
      for c in try(local.network_hierarchy[t == "group" ? "groups" : "regions"], []) : merge(c, {
        key  = c.name
        type = t
      })
    ]
  ])
  nh_l0_groups  = [for c in local.nh_l0_all : c if c.type == "group"]
  nh_l0_regions = [for c in local.nh_l0_all : c if c.type == "region"]

  nh_l1_all = flatten([
    for c in local.nh_l0_all : flatten([
      for t in ["group", "region"] : [
        for child in try(c[t == "group" ? "groups" : "regions"], []) : merge(child, {
          key        = "${c.key}/${child.name}"
          parent_key = c.key
          type       = t
        })
      ]
    ])
  ])
  nh_l1_groups  = [for c in local.nh_l1_all : c if c.type == "group"]
  nh_l1_regions = [for c in local.nh_l1_all : c if c.type == "region"]

  # Copy this block (rename l1->l2, l2->l3) to add an L3 level.
  nh_l2_all = flatten([
    for c in local.nh_l1_all : flatten([
      for t in ["group", "region"] : [
        for child in try(c[t == "group" ? "groups" : "regions"], []) : merge(child, {
          key        = "${c.key}/${child.name}"
          parent_key = c.key
          type       = t
        })
      ]
    ])
  ])
  nh_l2_groups  = [for c in local.nh_l2_all : c if c.type == "group"]
  nh_l2_regions = [for c in local.nh_l2_all : c if c.type == "region"]

  nh_all_containers = concat(local.nh_l0_all, local.nh_l1_all, local.nh_l2_all)

  # Scoped to exactly one level below - merging a level's own resources into a
  # map it also reads is a self-dependency cycle.
  nh_l0_names = merge(
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l0 : k => v.name },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l0 : k => v.name },
  )
  nh_l1_names = merge(
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l1 : k => v.name },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l1 : k => v.name },
  )
  # Combined across every level - safe because only sites read it, and sites
  # are never one of the maps being merged.
  nh_all_names = merge(
    local.nh_l0_names,
    local.nh_l1_names,
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_group_l2 : k => v.name },
    { for k, v in sdwan_network_hierarchy_node.network_hierarchy_region_l2 : k => v.name },
  )

  # Sites: declared directly under Global, or nested under a container at any level.
  nh_sites_flat = concat(
    [for s in try(local.network_hierarchy.sites, []) : merge(s, {
      key        = s.name
      parent_key = null
    })],
    flatten([
      for c in local.nh_all_containers : [for s in try(c.sites, []) : merge(s, {
        key        = "${c.key}/${s.name}"
        parent_key = c.key
      })]
    ]),
  )

}

resource "sdwan_network_hierarchy_node" "network_hierarchy_group_l0" {
  for_each     = { for c in local.nh_l0_groups : c.key => c }
  name         = each.value.name
  type         = "group"
  description  = try(each.value.description, null)
  parent_group = "Global"
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_region_l0" {
  for_each = { for c in local.nh_l0_regions : c.key => c }
  name     = each.value.name
  type     = "region"
  # Default false, not null: the API always returns a concrete false even when
  # unset, and is_secondary isn't Computed, so null here fails Terraform's
  # post-apply consistency check.
  is_secondary = try(each.value.is_secondary, false)
  description  = try(each.value.description, null)
  parent_group = "Global"
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_group_l1" {
  for_each     = { for c in local.nh_l1_groups : c.key => c }
  name         = each.value.name
  type         = "group"
  description  = try(each.value.description, null)
  parent_group = local.nh_l0_names[each.value.parent_key]
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_region_l1" {
  for_each     = { for c in local.nh_l1_regions : c.key => c }
  name         = each.value.name
  type         = "region"
  is_secondary = try(each.value.is_secondary, false)
  description  = try(each.value.description, null)
  parent_group = local.nh_l0_names[each.value.parent_key]
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_group_l2" {
  for_each     = { for c in local.nh_l2_groups : c.key => c }
  name         = each.value.name
  type         = "group"
  description  = try(each.value.description, null)
  parent_group = local.nh_l1_names[each.value.parent_key]
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_region_l2" {
  for_each     = { for c in local.nh_l2_regions : c.key => c }
  name         = each.value.name
  type         = "region"
  is_secondary = try(each.value.is_secondary, false)
  description  = try(each.value.description, null)
  parent_group = local.nh_l1_names[each.value.parent_key]
}

resource "sdwan_network_hierarchy_node" "network_hierarchy_site" {
  for_each     = { for s in local.nh_sites_flat : s.key => s }
  name         = each.value.name
  type         = "site"
  site_id      = each.value.site_id
  description  = try(each.value.description, null)
  address      = try(each.value.address, null)
  location     = try(each.value.location, null)
  latitude     = try(each.value.latitude, null)
  longitude    = try(each.value.longitude, null)
  parent_group = each.value.parent_key == null ? "Global" : local.nh_all_names[each.value.parent_key]
}

# Global-node settings, independent of the group/region/site hierarchy

resource "sdwan_network_hierarchy_cflowd" "network_hierarchy_cflowd" {
  count                  = try(local.network_hierarchy.collectors.cflowd, null) != null ? 1 : 0
  flow_active_timeout    = try(local.network_hierarchy.collectors.cflowd.settings.flow_active_timeout, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.flow_active_timeout)
  flow_inactive_timeout  = try(local.network_hierarchy.collectors.cflowd.settings.flow_inactive_timeout, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.flow_inactive_timeout)
  flow_refresh_time      = try(local.network_hierarchy.collectors.cflowd.settings.flow_refresh_time, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.flow_refresh_time)
  flow_sampling_interval = try(local.network_hierarchy.collectors.cflowd.settings.flow_sampling_interval, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.flow_sampling_interval)
  collect_tloc_loopback  = try(local.network_hierarchy.collectors.cflowd.settings.collect_tloc_loopback, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.collect_tloc_loopback)
  protocol               = try(local.network_hierarchy.collectors.cflowd.settings.protocol, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.protocol)
  collect_tos            = try(local.network_hierarchy.collectors.cflowd.settings.collect_tos, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.collect_tos)
  collect_dscp_output    = try(local.network_hierarchy.collectors.cflowd.settings.collect_dscp_output, local.defaults.sdwan.network_hierarchy.collectors.cflowd.settings.collect_dscp_output)
  collectors = try(local.network_hierarchy.collectors.cflowd.servers, null) == null ? null : [
    for c in local.network_hierarchy.collectors.cflowd.servers : {
      vpn_id             = c.vpn_id
      address            = c.address
      udp_port           = try(c.udp_port, local.defaults.sdwan.network_hierarchy.collectors.cflowd.servers.udp_port)
      export_spread      = try(c.export_spread, local.defaults.sdwan.network_hierarchy.collectors.cflowd.servers.export_spread)
      bfd_metrics_export = try(c.bfd_metrics_export, local.defaults.sdwan.network_hierarchy.collectors.cflowd.servers.bfd_metrics_export)
      export_interval    = try(c.bfd_metrics_export, local.defaults.sdwan.network_hierarchy.collectors.cflowd.servers.bfd_metrics_export) == true ? try(c.export_interval, local.defaults.sdwan.network_hierarchy.collectors.cflowd.servers.export_interval) : null
    }
  ]
}

resource "sdwan_network_hierarchy_security_logging" "network_hierarchy_security_logging" {
  count = try(local.network_hierarchy.collectors.security_logging, null) != null ? 1 : 0
  high_speed_logging = try(local.network_hierarchy.collectors.security_logging.high_speed_logging_servers, null) == null ? null : [
    for h in local.network_hierarchy.collectors.security_logging.high_speed_logging_servers : {
      vrf       = h.lan_vpn_name
      server_ip = h.server_ip
      port      = try(h.port, local.defaults.sdwan.network_hierarchy.collectors.security_logging.high_speed_logging_servers.port)
    }
  ]
  utd_syslog = try(local.network_hierarchy.collectors.security_logging.external_syslog_server, null) == null ? null : [
    {
      vpn       = local.network_hierarchy.collectors.security_logging.external_syslog_server.lan_vpn_name
      server_ip = local.network_hierarchy.collectors.security_logging.external_syslog_server.server_ip
    }
  ]
}
