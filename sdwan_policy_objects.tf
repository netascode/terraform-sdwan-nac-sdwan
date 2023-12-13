resource "sdwan_application_list_policy_object" "application_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.app, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    application        = try(e.app, null)
    application_family = try(e.appFamily, null)
  }]
}

resource "sdwan_as_path_list_policy_object" "as_path_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.asPath, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    as_path = e.asPath
  }]
}

resource "sdwan_class_map_policy_object" "class_map_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.class, {}) : p.name => p }
  name     = each.value.name
  queue    = each.value.entries[0].queue
}

resource "sdwan_color_list_policy_object" "color_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.color, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    color = e.color
  }]
}

resource "sdwan_standard_community_list_policy_object" "standard_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.community, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    community = e.community
  }]
}

resource "sdwan_data_ipv4_prefix_list_policy_object" "data_ipv4_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.dataPrefix, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    prefix = e.ipPrefix
  }]
}

resource "sdwan_expanded_community_list_policy_object" "expanded_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.expandedCommunity, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    community = e.community
  }]
}

resource "sdwan_extended_community_list_policy_object" "extended_community_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.extCommunity, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    community = e.community
  }]
}

resource "sdwan_policer_policy_object" "policer_policy_object" {
  for_each      = { for p in try(local.policy_objects.lists.policer, {}) : p.name => p }
  name          = each.value.name
  burst         = each.value.entries[0].burst
  exceed_action = each.value.entries[0].exceed
  rate          = each.value.entries[0].rate
}

resource "sdwan_ipv4_prefix_list_policy_object" "ipv4_prefix_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.prefix, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    prefix = e.ipPrefix
  }]
}

resource "sdwan_mirror_policy_object" "mirror_policy_object" {
  for_each              = { for p in try(local.policy_objects.lists.mirror, {}) : p.name => p }
  name                  = each.value.name
  remote_destination_ip = each.value.entries[0].remoteDest
  source_ip             = each.value.entries[0].source
}

resource "sdwan_site_list_policy_object" "site_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.site, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    site_id = e.siteId
  }]
}

resource "sdwan_sla_class_policy_object" "sla_class_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.sla, {}) : p.name => p }
  name     = each.value.name
  jitter   = each.value.entries[0].jitter
  latency  = each.value.entries[0].latency
  loss     = each.value.entries[0].loss
}

resource "sdwan_tloc_list_policy_object" "tloc_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.tloc, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    color         = e.color
    encapsulation = e.encap
    tloc_ip       = e.tloc
  }]
}

resource "sdwan_vpn_list_policy_object" "vpn_list_policy_object" {
  for_each = { for p in try(local.policy_objects.lists.vpn, {}) : p.name => p }
  name     = each.value.name
  entries = [for e in try(each.value.entries, []) : {
    vpn_id = e.vpn
  }]
}
