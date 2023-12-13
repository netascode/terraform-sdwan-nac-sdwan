locals {
  device_types = [
    "C8000V",
    "C8300-1N1S-4T2X",
    "C8300-1N1S-6T",
    "C8300-2N2S-6T",
    "C8300-2N2S-4T2X",
    "C8500-12X4QC",
    "C8500-12X",
    "C8500-20X6C",
    "C8500L-8S4X",
    "C8200-1N-4T",
    "C8200L-1N-4T"
  ]
  thousand_eyes_device_types = [
    "C8300-1N1S-4T2X",
    "C8300-1N1S-6T",
    "C8300-2N2S-6T",
    "C8300-2N2S-4T2X",
    "C8200-1N-4T",
    "C8200L-1N-4T"
  ]
}

resource "sdwan_cedge_aaa_feature_template" "cedge_aaa_feature_template" {
  for_each                     = { for t in try(local.cedge_feature_templates.cedge_aaa, {}) : t.name => t }
  name                         = each.value.name
  description                  = each.value.description
  device_types                 = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  server_groups_priority_order = try(each.value.parameters.server-auth-order, local.defaults.sdwan.cedge_feature_templates.cedge_aaa.parameters.server-auth-order)
  users = try(length(each.value.parameters.user) == 0, true) ? null : [for user in each.value.parameters.user : {
    name            = user.name
    password        = user.password
    secret          = user.secret
    privilege_level = user.privilege
    optional        = try(user.optional, null)
  }]
  radius_server_groups = try(length(each.value.parameters.radius) == 0, true) ? null : [for group in each.value.parameters.radius : {
    group_name                = group.group-name
    vpn_id                    = try(group.vpn, null)
    source_interface          = startswith(try(group.source-interface, ""), "DEVICE_VARIABLE;") ? null : group.source-interface
    source_interface_variable = startswith(try(group.source-interface, ""), "DEVICE_VARIABLE;") ? split(";", group.source-interface)[1] : null
    servers = !can(group.server) ? null : [for server in group.server : {
      address             = server.address
      authentication_port = try(server.auth-port, null)
      accounting_port     = try(server.acct-port, null)
      timeout             = try(server.timeout, null)
      retransmit          = try(server.retransmit, null)
      key                 = server.key
      secret_key          = server.secret-key
      encryption_type     = try(server.key-enum, null)
      key_type            = try(server.key-type, null)
    }]
  }]
  tacacs_server_groups = try(length(each.value.parameters.tacacs) == 0, true) ? null : [for group in each.value.parameters.tacacs : {
    group_name                = group.group-name
    vpn_id                    = try(group.vpn, null)
    source_interface          = startswith(try(group.source-interface, ""), "DEVICE_VARIABLE;") ? null : group.source-interface
    source_interface_variable = startswith(try(group.source-interface, ""), "DEVICE_VARIABLE;") ? split(";", group.source-interface)[1] : null
    servers = try(length(group.server) == 0, true) ? null : [for server in group.server : {
      address         = server.address
      key             = server.key
      secret_key      = server.secret-key
      encryption_type = try(server.key-enum, null)
      key_type        = try(server.key-type, null)
      port            = try(server.port, null)
      timeout         = try(server.timeout, null)
    }]
  }]
  accounting_rules = try(length(each.value.parameters.accounting.accounting-rule) == 0, true) ? null : [for rule in each.value.parameters.accounting.accounting-rule : {
    name               = rule.rule-id
    method             = rule.method
    privilege_level    = try(rule.privilege-level, null)
    start_stop         = startswith(try(rule.start-stop, ""), "DEVICE_VARIABLE;") ? null : rule.start-stop
    startstop_variable = startswith(try(rule.start-stop, ""), "DEVICE_VARIABLE;") ? split(";", rule.start-stop)[1] : null
    groups             = rule.group
  }]
  authorization_console                  = startswith(try(each.value.parameters.authorization.authorization-console, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.authorization.authorization-console, null)
  authorization_console_variable         = startswith(try(each.value.parameters.authorization.authorization-console, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.authorization.authorization-console)[1] : null
  authorization_config_commands          = startswith(try(each.value.parameters.authorization.authorization-config-commands, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.authorization.authorization-config-commands, null)
  authorization_config_commands_variable = startswith(try(each.value.parameters.authorization.authorization-config-commands, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.authorization.authorization-config-commands)[1] : null
  authorization_rules = try(length(each.value.parameters.authorization.authorization-rule) == 0, true) ? null : [for rule in each.value.parameters.authorization.authorization-rule : {
    name            = rule.rule-id
    method          = rule.method
    privilege_level = rule.level
    groups          = rule.group
    authenticated   = rule.if-authenticated
  }]
}

resource "sdwan_cedge_global_feature_template" "cedge_global_feature_template" {
  for_each                  = { for t in try(local.cedge_feature_templates.cedge_global, {}) : t.name => t }
  name                      = each.value.name
  description               = each.value.description
  device_types              = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  nat64_udp_timeout         = try(each.value.parameters.nat64-global.nat64-timeout.udp-timeout, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.nat64-global.nat64-timeout.udp-timeout)
  nat64_tcp_timeout         = try(each.value.parameters.nat64-global.nat64-timeout.tcp-timeout, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.nat64-global.nat64-timeout.tcp-timeout)
  http_authentication       = try(each.value.parameters.http-global.http-authentication, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.http-global.http-authentication)
  ssh_version               = try(each.value.parameters.ssh.version, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.ssh.version)
  http_server               = try(each.value.parameters.services-global.services-ip.http-server, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.http-server)
  https_server              = try(each.value.parameters.services-global.services-ip.https-server, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.https-server)
  source_interface          = startswith(try(each.value.parameters.services-global.services-ip.source-intrf, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.services-global.services-ip.source-intrf, null)
  source_interface_variable = startswith(try(each.value.parameters.services-global.services-ip.source-intrf, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.services-global.services-ip.source-intrf)[1] : null
  ip_source_routing         = try(each.value.parameters.services-global.services-other.source-route, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.source-route)
  arp_proxy                 = try(each.value.parameters.services-global.services-ip.arp-proxy, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.arp-proxy)
  ftp_passive               = try(each.value.parameters.services-global.services-ip.ftp-passive, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.ftp-passive)
  rsh_rcp                   = try(each.value.parameters.services-global.services-ip.rcmd, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.rcmd)
  bootp                     = try(each.value.parameters.services-global.services-other.bootp, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.bootp)
  domain_lookup             = startswith(try(each.value.parameters.services-global.services-ip.domain-lookup, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.services-global.services-ip.domain-lookup, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.domain-lookup)
  domain_lookup_variable    = startswith(try(each.value.parameters.services-global.services-ip.domain-lookup, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.services-global.services-ip.domain-lookup)[1] : null
  tcp_keepalives_out        = try(each.value.parameters.services-global.services-other.tcp-keepalives-out, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.tcp-keepalives-out)
  tcp_keepalives_in         = try(each.value.parameters.services-global.services-other.tcp-keepalives-in, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.tcp-keepalives-in)
  tcp_small_servers         = try(each.value.parameters.services-global.services-other.tcp-small-servers, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.tcp-small-servers)
  udp_small_servers         = try(each.value.parameters.services-global.services-other.udp-small-servers, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.udp-small-servers)
  lldp                      = startswith(try(each.value.parameters.services-global.services-ip.lldp, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.services-global.services-ip.lldp, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.lldp)
  lldp_variable             = startswith(try(each.value.parameters.services-global.services-ip.lldp, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.services-global.services-ip.lldp)[1] : null
  cdp                       = startswith(try(each.value.parameters.services-global.services-ip.cdp, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.services-global.services-ip.cdp, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.cdp)
  cdp_variable              = startswith(try(each.value.parameters.services-global.services-ip.cdp, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.services-global.services-ip.cdp)[1] : null
  snmp_ifindex_persist      = try(each.value.parameters.services-global.services-other.snmp-ifindex-persist, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.snmp-ifindex-persist)
  console_logging           = try(each.value.parameters.services-global.services-other.console-logging, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.console-logging)
  vty_logging               = try(each.value.parameters.services-global.services-other.vty-logging, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-other.vty-logging)
  line_vty                  = try(each.value.parameters.services-global.services-ip.line-vty, local.defaults.sdwan.cedge_feature_templates.cedge_global.parameters.services-global.services-ip.line-vty)
}

resource "sdwan_cisco_banner_feature_template" "cisco_banner_feature_template" {
  for_each     = { for t in try(local.cedge_feature_templates.cisco_banner, {}) : t.name => t }
  name         = each.value.name
  description  = each.value.description
  device_types = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  login        = try(each.value.parameters.login, null)
  motd         = try(each.value.parameters.motd, null)
}

resource "sdwan_cisco_bfd_feature_template" "cisco_bfd_feature_template" {
  for_each      = { for t in try(local.cedge_feature_templates.cisco_bfd, {}) : t.name => t }
  name          = each.value.name
  description   = each.value.description
  device_types  = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  multiplier    = try(each.value.parameters.app-route.multiplier, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.app-route.multiplier)
  poll_interval = try(each.value.parameters.app-route.poll-interval, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.app-route.poll-interval)
  default_dscp  = try(each.value.parameters.default-dscp, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.default-dscp)
  colors = try(length(each.value.parameters.color) == 0, true) ? null : [for color in each.value.parameters.color : {
    color          = color.color
    hello_interval = try(color.hello-interval, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.color.hello-interval)
    multiplier     = try(color.multiplier, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.color.multiplier)
    pmtu_discovery = try(color.pmtu-discovery, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.color.pmtu-discovery)
    dscp           = try(color.dscp, local.defaults.sdwan.cedge_feature_templates.cisco_bfd.parameters.color.dscp)
  }]
}

resource "sdwan_cisco_bgp_feature_template" "cisco_bgp_feature_template" {
  for_each                     = { for t in try(local.cedge_feature_templates.cisco_bgp, {}) : t.name => t }
  name                         = each.value.name
  description                  = each.value.description
  device_types                 = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  as_number                    = startswith(try(each.value.parameters.bgp.as-num, ""), "DEVICE_VARIABLE;") ? null : each.value.parameters.bgp.as-num
  as_number_variable           = startswith(try(each.value.parameters.bgp.as-num, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.as-num)[1] : null
  shutdown                     = startswith(try(each.value.parameters.bgp.shutdown, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.shutdown, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.shutdown)
  shutdown_variable            = startswith(try(each.value.parameters.bgp.shutdown, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.shutdown)[1] : null
  router_id                    = startswith(try(each.value.parameters.bgp.router-id, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.router-id, null)
  router_id_variable           = startswith(try(each.value.parameters.bgp.router-id, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.router-id)[1] : null
  propagate_aspath             = startswith(try(each.value.parameters.bgp.propagate-aspath, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.propagate-aspath, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.propagate-aspath)
  propagate_aspath_variable    = startswith(try(each.value.parameters.bgp.propagate-aspath, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.propagate-aspath)[1] : null
  propagate_community          = startswith(try(each.value.parameters.bgp.propagate-community, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.propagate-community, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.propagate-community)
  propagate_community_variable = startswith(try(each.value.parameters.bgp.propagate-community, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.propagate-community)[1] : null
  distance_external            = startswith(try(each.value.parameters.bgp.distance.external, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.distance.external, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.distance.external)
  distance_external_variable   = startswith(try(each.value.parameters.bgp.distance.external, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.distance.external)[1] : null
  distance_internal            = startswith(try(each.value.parameters.bgp.distance.internal, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.distance.internal, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.distance.internal)
  distance_internal_variable   = startswith(try(each.value.parameters.bgp.distance.internal, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.distance.internal)[1] : null
  distance_local               = startswith(try(each.value.parameters.bgp.distance.local, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.distance.local, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.distance.local)
  distance_local_variable      = startswith(try(each.value.parameters.bgp.distance.local, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.distance.local)[1] : null
  keepalive                    = startswith(try(each.value.parameters.bgp.timers.keepalive, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.timers.keepalive, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.timers.keepalive)
  keepalive_variable           = startswith(try(each.value.parameters.bgp.timers.keepalive, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.timers.keepalive)[1] : null
  holdtime                     = startswith(try(each.value.parameters.bgp.timers.holdtime, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bgp.timers.holdtime, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.timers.holdtime)
  holdtime_variable            = startswith(try(each.value.parameters.bgp.timers.holdtime, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bgp.timers.holdtime)[1] : null
  always_compare_med           = try(each.value.parameters.bgp.best-path.med.always-compare, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.best-path.med.always-compare)
  deterministic_med            = try(each.value.parameters.bgp.best-path.med.deterministic, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.best-path.med.deterministic)
  missing_med_worst            = try(each.value.parameters.bgp.best-path.med.missing-as-worst, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.best-path.med.deterministic)
  compare_router_id            = try(each.value.parameters.bgp.best-path.compare-router-id, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.best-path.med.missing-as-worst)
  multipath_relax              = try(each.value.parameters.bgp.best-path.as-path.multipath-relax, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.best-path.as-path.multipath-relax)
  address_families = try(length(each.value.parameters.bgp.address-family) == 0, true) ? null : [for af in each.value.parameters.bgp.address-family : {
    family_type                            = try(af.family_type, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.address-family.family-type)
    maximum_paths                          = startswith(try(af.maximum-paths.paths, ""), "DEVICE_VARIABLE;") ? null : try(af.maximum-paths.paths, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.address-family.maximum-paths.paths)
    maximum_paths_variable                 = startswith(try(af.maximum-paths.paths, ""), "DEVICE_VARIABLE;") ? split(";", af.maximum-paths.paths)[1] : null
    default_information_originate          = startswith(try(af.default-information.originate, ""), "DEVICE_VARIABLE;") ? null : try(af.default-information.originate, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.address-family.default-information.originate)
    default_information_originate_variable = startswith(try(af.default-information.originate, ""), "DEVICE_VARIABLE;") ? split(";", af.default-information.originate)[1] : null
    redistribute_routes = try(length(af.redistribute) == 0, true) ? null : [for r in af.redistribute : {
      protocol              = r.protocol
      route_policy          = startswith(try(r.route_policy, ""), "DEVICE_VARIABLE;") ? null : try(r.route_policy, null)
      route_policy_variable = startswith(try(r.route_policy, ""), "DEVICE_VARIABLE;") ? split(";", r.route_policy)[1] : null
      optional              = try(r.optional, null)
    }]
  }]
  ipv4_neighbors = try(length(each.value.parameters.bgp.neighbor) == 0, true) ? null : [for n in each.value.parameters.bgp.neighbor : {
    address                     = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? null : try(n.address, null)
    address_variable            = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? split(";", n.address)[1] : null
    shutdown                    = startswith(try(n.shutdown, ""), "DEVICE_VARIABLE;") ? null : try(n.shutdown, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.shutdown)
    shutdown_variable           = startswith(try(n.shutdown, ""), "DEVICE_VARIABLE;") ? split(";", n.shutdown)[1] : null
    remote_as                   = startswith(try(n.remote-as, ""), "DEVICE_VARIABLE;") ? null : try(n.remote-as, null)
    remote_as_variable          = startswith(try(n.remote-as, ""), "DEVICE_VARIABLE;") ? split(";", n.remote-as)[1] : null
    keepalive                   = startswith(try(n.timers.keepalive, ""), "DEVICE_VARIABLE;") ? null : try(n.timers.keepalive, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.timers.keepalive)
    keepalive_variable          = startswith(try(n.timers.keepalive, ""), "DEVICE_VARIABLE;") ? split(";", n.timers.keepalive)[1] : null
    holdtime                    = startswith(try(n.timers.holdtime, ""), "DEVICE_VARIABLE;") ? null : try(n.timers.holdtime, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.timers.holdtime)
    holdtime_variable           = startswith(try(n.timers.holdtime, ""), "DEVICE_VARIABLE;") ? split(";", n.timers.holdtime)[1] : null
    next_hop_self               = startswith(try(n.next-hop-self, ""), "DEVICE_VARIABLE;") ? null : try(n.next-hop-self, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.next-hop-self)
    next_hop_self_variable      = startswith(try(n.next-hop-self, ""), "DEVICE_VARIABLE;") ? split(";", n.next-hop-self)[1] : null
    send_community              = startswith(try(n.send-community, ""), "DEVICE_VARIABLE;") ? null : try(n.send-community, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.send-community)
    send_community_variable     = startswith(try(n.send-community, ""), "DEVICE_VARIABLE;") ? split(";", n.send-community)[1] : null
    send_ext_community          = startswith(try(n.send-ext-community, ""), "DEVICE_VARIABLE;") ? null : try(n.send-ext-community, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.send-ext-community)
    send_ext_community_variable = startswith(try(n.send-ext-community, ""), "DEVICE_VARIABLE;") ? split(";", n.send-ext-community)[1] : null
    ebgp_multihop               = startswith(try(n.ebgp-multihop, ""), "DEVICE_VARIABLE;") ? null : try(n.bgp-multihop, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.ebgp-multihop)
    ebgp_multihop_variable      = startswith(try(n.bgp-multihop, ""), "DEVICE_VARIABLE;") ? split(";", n.bgp-multihop)[1] : null
    password                    = startswith(try(n.password, ""), "DEVICE_VARIABLE;") ? null : try(n.password, null)
    password_variable           = startswith(try(n.password, ""), "DEVICE_VARIABLE;") ? split(";", n.password)[1] : null
    address_families = try(length(n.address-family) == 0, true) ? null : [for af in n.address-family : {
      family_type      = try(af.family-type, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.address-family.family-type)
      maximum_prefixes = try(af.maximum-prefixes.prefix-num, local.defaults.sdwan.cedge_feature_templates.cisco_bgp.parameters.bgp.neighbor.address-family.maximum-prefixes.prefix-num)
      route_policies = try(length(af.route-policy) == 0, true) ? null : [for rp in af.route-policy : {
        direction            = rp.direction
        policy_name          = startswith(try(rp.pol-name, ""), "DEVICE_VARIABLE;") ? null : try(rp.pol-name, null)
        policy_name_variable = startswith(try(rp.pol-name, ""), "DEVICE_VARIABLE;") ? split(";", rp.pol-name)[1] : null
      }]
    }]
    optional = try(n.optional, null)
  }]
}

resource "sdwan_cisco_ospf_feature_template" "cisco_ospf_feature_template" {
  for_each                                           = { for t in try(local.cedge_feature_templates.cisco_ospf, {}) : t.name => t }
  name                                               = each.value.name
  description                                        = each.value.description
  device_types                                       = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  router_id                                          = startswith(try(each.value.parameters.ospf.router-id, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.router-id, null)
  router_id_variable                                 = startswith(try(each.value.parameters.ospf.router-id, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.router-id)[1] : null
  auto_cost_reference_bandwidth                      = startswith(try(each.value.parameters.ospf.auto-cost.reference-bandwidth, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.auto-cost.reference-bandwidth, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.reference-bandwidth)
  auto_cost_reference_bandwidth_variable             = startswith(try(each.value.parameters.ospf.auto-cost.reference-bandwidth, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.auto-cost.reference-bandwidth)[1] : null
  compatible_rfc1583                                 = startswith(try(each.value.parameters.ospf.compatible.rfc1583, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.compatible.rfc1583, null)
  compatible_rfc1583_variable                        = startswith(try(each.value.parameters.ospf.compatible.rfc1583, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.compatible.rfc1583)[1] : null
  default_information_originate                      = try(tobool(each.value.parameters.ospf.default-information.originate), false) ? tobool(each.value.parameters.ospf.default-information.originate) : true
  default_information_originate_always               = startswith(try(each.value.parameters.ospf.default-information.originate.always, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.default-information.originate.always, null)
  default_information_originate_always_variable      = startswith(try(each.value.parameters.ospf.default-information.originate.always, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.default-information.originate.always)[1] : null
  default_information_originate_metric               = startswith(try(each.value.parameters.ospf.default-information.originate.metric, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.default-information.originate.metric, null)
  default_information_originate_metric_variable      = startswith(try(each.value.parameters.ospf.default-information.originate.metric, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.default-information.originate.metric)[1] : null
  default_information_originate_metric_type          = startswith(try(each.value.parameters.ospf.default-information.originate.metric-type, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.default-information.originate.metric-type, null)
  default_information_originate_metric_type_variable = startswith(try(each.value.parameters.ospf.default-information.originate.metric-type, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.default-information.originate.metric-type)[1] : null
  distance_external                                  = startswith(try(each.value.parameters.ospf.distance.external, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.distance.external, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.distance.external)
  distance_external_variable                         = startswith(try(each.value.parameters.ospf.distance.external, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.distance.external)[1] : null
  distance_inter_area                                = startswith(try(each.value.parameters.ospf.distance.inter-area, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.distance.inter-area, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.distance.inter-area)
  distance_inter_area_variable                       = startswith(try(each.value.parameters.ospf.distance.inter-area, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.distance.inter-area)[1] : null
  distance_intra_area                                = startswith(try(each.value.parameters.ospf.distance.intra-area, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.distance.intra-area, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.distance.intra-area)
  distance_intra_area_variable                       = startswith(try(each.value.parameters.ospf.distance.intra-area, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.distance.intra-area)[1] : null
  timers_spf_delay                                   = startswith(try(each.value.parameters.ospf.timers.spf.delay, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.timers.spf.delay, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.timers.spf.delay, null)
  timers_spf_delay_variable                          = startswith(try(each.value.parameters.ospf.timers.spf.delay, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.timers.spf.delay)[1] : null
  timers_spf_initial_hold                            = startswith(try(each.value.parameters.ospf.timers.spf.initial-hold, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.timers.spf.initial-hold, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.timers.spf.initial-hold)
  timers_spf_initial_hold_variable                   = startswith(try(each.value.parameters.ospf.timers.spf.initial-hold, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.timers.spf.initial-hold)[1] : null
  timers_spf_max_hold                                = startswith(try(each.value.parameters.ospf.timers.spf.max-hold, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ospf.timers.spf.max-hold, local.defaults.sdwan.cedge_feature_templates.cisco_ospf.parameters.ospf.timers.spf.max-hold)
  timers_spf_max_hold_variable                       = startswith(try(each.value.parameters.ospf.timers.spf.max-hold, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ospf.timers.spf.max-hold)[1] : null
  redistribute = try(length(each.value.parameters.ospf.redistribute) == 0, true) ? null : [for r in each.value.parameters.ospf.redistribute : {
    protocol              = r.protocol
    route_policy          = startswith(try(r.route-policy, ""), "DEVICE_VARIABLE;") ? null : try(r.route-policy, null)
    route_policy_variable = startswith(try(r.route-policy, ""), "DEVICE_VARIABLE;") ? split(";", r.route-policy)[1] : null
    nat_dia               = startswith(try(r.nat_dia, ""), "DEVICE_VARIABLE;") ? null : try(r.nat_dia, null)
    nat_dia_variable      = startswith(try(r.nat_dia, ""), "DEVICE_VARIABLE;") ? split(";", r.nat_dia)[1] : null
    optional              = try(r.optional, null)
  }]
  max_metric_router_lsa = try(length(each.value.parameters.ospf.max_metric_router_lsa) == 0, true) ? null : [for r in each.value.parameters.ospf.max_metric_router_lsa : {
    ad_type       = r.ad_type
    time          = startswith(try(r.time, ""), "DEVICE_VARIABLE;") ? null : try(r.time, null)
    time_variable = startswith(try(r.time, ""), "DEVICE_VARIABLE;") ? split(";", r.time)[1] : null
  }]
  route_policies = try(length(each.value.parameters.ospf.route-policy) == 0, true) ? null : [for r in each.value.parameters.ospf.route-policy : {
    direction            = r.direction
    policy_name          = startswith(try(r.pol-name, ""), "DEVICE_VARIABLE;") ? null : try(r.pol-name, null)
    policy_name_variable = startswith(try(r.pol-name, ""), "DEVICE_VARIABLE;") ? split(";", r.pol-name)[1] : null
  }]
  areas = try(length(each.value.parameters.ospf.area) == 0, true) ? null : [for a in each.value.parameters.ospf.area : {
    area_number = startswith(try(a.a-num, ""), "DEVICE_VARIABLE;") ? null : try(a.a-num, null)
    interfaces = try(length(a.interface) == 0, true) ? null : [for an in a.interface : {
      name                                          = startswith(try(an.name, ""), "DEVICE_VARIABLE;") ? null : try(an.name, null)
      name_variable                                 = startswith(try(an.name, ""), "DEVICE_VARIABLE;") ? split(";", an.name)[1] : null
      hello_interval                                = startswith(try(an.hello-interval, ""), "DEVICE_VARIABLE;") ? null : try(an.hello-interval, null)
      hello_interval_variable                       = startswith(try(an.hello-interval, ""), "DEVICE_VARIABLE;") ? split(";", an.hello-interval)[1] : null
      dead_interval                                 = startswith(try(an.dead-interval, ""), "DEVICE_VARIABLE;") ? null : try(an.dead-interval, null)
      dead_interval_variable                        = startswith(try(an.dead-interval, ""), "DEVICE_VARIABLE;") ? split(";", an.dead-interval)[1] : null
      retransmit_interval                           = startswith(try(an.retransmit-interval, ""), "DEVICE_VARIABLE;") ? null : try(an.retransmit-interval, null)
      retransmit_interval_variable                  = startswith(try(an.retransmit-interval, ""), "DEVICE_VARIABLE;") ? split(";", an.retransmit-interval)[1] : null
      cost                                          = startswith(try(an.cost, ""), "DEVICE_VARIABLE;") ? null : try(an.cost, null)
      cost_variable                                 = startswith(try(an.cost, ""), "DEVICE_VARIABLE;") ? split(";", an.cost)[1] : null
      priority                                      = startswith(try(an.priority, ""), "DEVICE_VARIABLE;") ? null : try(an.priority, null)
      priority_variable                             = startswith(try(an.priority, ""), "DEVICE_VARIABLE;") ? split(";", an.priority)[1] : null
      network                                       = startswith(try(an.network, ""), "DEVICE_VARIABLE;") ? null : try(an.network, null)
      network_variable                              = startswith(try(an.network, ""), "DEVICE_VARIABLE;") ? split(";", an.network)[1] : null
      passive_interface                             = startswith(try(an.passive-interface, ""), "DEVICE_VARIABLE;") ? null : try(an.passive-interface, null)
      passive_interface_variable                    = startswith(try(an.passive-interface, ""), "DEVICE_VARIABLE;") ? split(";", an.passive-interface)[1] : null
      authentication_type                           = startswith(try(an.authentication.type, ""), "DEVICE_VARIABLE;") ? null : try(an.authentication.type, null)
      authentication_type_variable                  = startswith(try(an.authentication.type, ""), "DEVICE_VARIABLE;") ? split(";", an.authentication.type)[1] : null
      authentication_message_digest_key_id          = startswith(try(an.authentication.message-digest.message-digest-key, ""), "DEVICE_VARIABLE;") ? null : try(an.authentication.message-digest.message-digest-key, null)
      authentication_message_digest_key_id_variable = startswith(try(an.authentication.message-digest.message-digest-key, ""), "DEVICE_VARIABLE;") ? split(";", an.authentication.message-digest.message-digest-key)[1] : null
      authentication_message_digest_key             = startswith(try(an.authentication.message-digest.md5, ""), "DEVICE_VARIABLE;") ? null : try(an.authentication.message-digest.md5, null)
      authentication_message_digest_key_variable    = startswith(try(an.authentication.message-digest.md5, ""), "DEVICE_VARIABLE;") ? split(";", an.authentication.message-digest.md5)[1] : null
    }]
    ranges = try(length(a.range) == 0, true) ? null : [for an in a.range : {
      address               = startswith(try(an.address, ""), "DEVICE_VARIABLE;") ? null : try(an.address, null)
      address_variable      = startswith(try(an.address, ""), "DEVICE_VARIABLE;") ? split(";", an.address)[1] : null
      cost                  = startswith(try(an.cost, ""), "DEVICE_VARIABLE;") ? null : try(an.cost, null)
      cost_variable         = startswith(try(an.cost, ""), "DEVICE_VARIABLE;") ? split(";", an.cost)[1] : null
      no_advertise          = startswith(try(an.no_advertise, ""), "DEVICE_VARIABLE;") ? null : try(an.no_advertise, null)
      no_advertise_variable = startswith(try(an.no_advertise, ""), "DEVICE_VARIABLE;") ? split(";", an.no_advertise)[1] : null
    }]
    optional = try(a.optional, null)
  }]
}

resource "sdwan_cisco_logging_feature_template" "cisco_logging_feature_template" {
  for_each      = { for t in try(local.cedge_feature_templates.cisco_logging, {}) : t.name => t }
  name          = each.value.name
  description   = each.value.description
  device_types  = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  disk_logging  = try(each.value.parameters.disk.enable, local.defaults.sdwan.cedge_feature_templates.cisco_logging.parameters.disk.enable)
  max_size      = try(each.value.parameters.disk.file.size, local.defaults.sdwan.cedge_feature_templates.cisco_logging.parameters.disk.file.size)
  log_rotations = try(each.value.parameters.disk.file.rotate, local.defaults.sdwan.cedge_feature_templates.cisco_logging.parameters.disk.file.rotate)
  ipv4_servers = try(length(each.value.parameters.server) == 0, true) ? null : [for server in each.value.parameters.server : {
    hostname_ip               = startswith(try(server.name, ""), "DEVICE_VARIABLE;") ? null : try(server.name, null)
    hostname_ip_variable      = startswith(try(server.name, ""), "DEVICE_VARIABLE;") ? split(";", server.name)[1] : null
    vpn_id                    = startswith(try(server.vpn, ""), "DEVICE_VARIABLE;") ? null : try(server.vpn, null)
    vpn_id_variable           = startswith(try(server.vpn, ""), "DEVICE_VARIABLE;") ? split(";", server.vpn)[1] : null
    source_interface          = startswith(try(server.source-interface, ""), "DEVICE_VARIABLE;") ? null : try(server.source-interface, null)
    source_interface_variable = startswith(try(server.source-interface, ""), "DEVICE_VARIABLE;") ? split(";", server.source-interface)[1] : null
    logging_level             = try(server.tls.priority, null)
    enable_tls                = try(server.tls.enable-tls, null)
  }]
}

resource "sdwan_cisco_ntp_feature_template" "cisco_ntp_feature_template" {
  for_each     = { for t in try(local.cedge_feature_templates.cisco_ntp, {}) : t.name => t }
  name         = each.value.name
  description  = each.value.description
  device_types = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  servers = try(length(each.value.parameters.server) == 0, true) ? null : [for server in each.value.parameters.server : {
    hostname_ip               = server.name
    version                   = try(server.version, local.defaults.sdwan.cedge_feature_templates.cisco_ntp.parameters.server.version)
    vpn_id                    = try(server.vpn, local.defaults.sdwan.cedge_feature_templates.cisco_ntp.parameters.server.vpn)
    source_interface          = startswith(try(server.source-interface, ""), "DEVICE_VARIABLE;") ? null : try(server.source-interface, null)
    source_interface_variable = startswith(try(server.source-interface, ""), "DEVICE_VARIABLE;") ? split(";", server.source-interface)[1] : null
    prefer                    = try(server.prefer, null)
  }]
}

resource "sdwan_cisco_omp_feature_template" "cisco_omp_feature_template" {
  for_each                = { for t in try(local.cedge_feature_templates.cisco_omp, {}) : t.name => t }
  name                    = each.value.name
  description             = each.value.description
  device_types            = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  graceful_restart        = try(each.value.parameters.graceful-restart, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.graceful-restart)
  overlay_as              = try(each.value.parameters.overlay-as, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.overlay-as)
  send_path_limit         = try(each.value.parameters.send-path-limit, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.send-path-limit)
  ecmp_limit              = try(each.value.parameters.ecmp-limit, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.ecmp-limit)
  shutdown                = try(each.value.parameters.shutdown, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.shutdown)
  omp_admin_distance_ipv4 = try(each.value.parameters.omp-admin-distance-ipv4, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.omp-admin-distance-ipv4)
  omp_admin_distance_ipv6 = try(each.value.parameters.omp-admin-distance-ipv6, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.omp-admin-distance-ipv6)
  advertisement_interval  = try(each.value.parameters.timers.advertisement-interval, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.timers.advertisement-interval)
  graceful_restart_timer  = try(each.value.parameters.timers.graceful-restart-timer, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.timers.graceful-restart-timer)
  eor_timer               = try(each.value.parameters.timers.eor-timer, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.timers.eor-timer)
  holdtime                = try(each.value.parameters.timers.holdtime, local.defaults.sdwan.cedge_feature_templates.cisco_omp.parameters.timers.holdtime)
  advertise_ipv4_routes = try(length(each.value.parameters.advertise) == 0, true) ? null : [for a in each.value.parameters.advertise : {
    protocol = a.protocol
  }]
}

resource "sdwan_cisco_security_feature_template" "cisco_security_feature_template" {
  for_each            = { for t in try(local.cedge_feature_templates.cisco_security, {}) : t.name => t }
  name                = each.value.name
  description         = each.value.description
  device_types        = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  rekey_interval      = try(each.value.parameters.ipsec.rekey, local.defaults.sdwan.cedge_feature_templates.cisco_security.parameters.ipsec.rekey)
  replay_window       = try(each.value.parameters.ipsec.replay-window, local.defaults.sdwan.cedge_feature_templates.cisco_security.parameters.ipsec.replay-window)
  extended_ar_window  = try(each.value.parameters.ipsec.extended-ar-window, local.defaults.sdwan.cedge_feature_templates.cisco_security.parameters.ipsec.extended-ar-window)
  authentication_type = try(each.value.parameters.ipsec.authentication-type, local.defaults.sdwan.cedge_feature_templates.cisco_security.parameters.ipsec.authentication-type)
  integrity_type      = try(each.value.parameters.ipsec.integrity-type, local.defaults.sdwan.cedge_feature_templates.cisco_security.parameters.ipsec.integrity-type)
}

resource "sdwan_cisco_sig_credentials_feature_template" "cisco_sig_credentials_feature_template" {
  for_each                 = { for t in try(local.cedge_feature_templates.cisco_sig_credentials, {}) : t.name => t }
  name                     = each.value.name
  description              = each.value.description
  device_types             = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  zscaler_organization     = try(each.value.parameters.zscaler.organization, null)
  zscaler_partner_base_uri = try(each.value.parameters.zscaler.partner-base-url, null)
  zscaler_username         = try(each.value.parameters.zscaler.username, null)
  zscaler_password         = try(each.value.parameters.zscaler.password, null)
  zscaler_partner_api_key  = try(each.value.parameters.zscaler.api-key, null)
  umbrella_api_key         = try(each.value.parameters.umbrella.api-key, null)
  umbrella_api_secret      = try(each.value.parameters.umbrella.api-secret, null)
  umbrella_organization_id = try(each.value.parameters.umbrella.org-id, null)
}

resource "sdwan_cisco_snmp_feature_template" "cisco_snmp_feature_template" {
  for_each          = { for t in try(local.cedge_feature_templates.cisco_snmp, {}) : t.name => t }
  name              = each.value.name
  description       = each.value.description
  device_types      = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  shutdown          = startswith(try(each.value.parameters.shutdown, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.shutdown, local.defaults.sdwan.cedge_feature_templates.cisco_snmp.parameters.shutdown)
  shutdown_variable = startswith(try(each.value.parameters.shutdown, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.shutdown)[1] : null
  contact           = startswith(try(each.value.parameters.contact, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.contact, null)
  contact_variable  = startswith(try(each.value.parameters.contact, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.contact)[1] : null
  location          = startswith(try(each.value.parameters.location, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.location, null)
  location_variable = startswith(try(each.value.parameters.location, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.location)[1] : null
  views = try(length(each.value.parameters.view) == 0, true) ? null : [for v in each.value.parameters.view : {
    name = v.name
    object_identifiers = try(length(v.oid) == 0, true) ? null : [for o in v.oid : {
      id      = o.id
      exclude = try(o.exclude, null)
    }]
  }]
  communities = try(length(each.value.parameters.community) == 0, true) ? null : [for c in each.value.parameters.community : {
    name          = c.name
    view          = c.view
    authorization = c.authorization
  }]
  groups = try(length(each.value.parameters.group) == 0, true) ? null : [for g in each.value.parameters.group : {
    name           = g.name
    security_level = g.security-level
    view           = g.view
  }]
  users = try(length(each.value.parameters.user) == 0, true) ? null : [for u in each.value.parameters.user : {
    name                    = u.name
    authentication_protocol = try(u.auth, null)
    authentication_password = try(u.auth-password, null)
    privacy_protocol        = try(u.priv, null)
    privacy_password        = try(u.priv-password, null)
    group                   = u.group
  }]
  trap_targets = try(length(each.value.parameters.trap.target) == 0, true) ? null : [for t in each.value.parameters.trap.target : {
    vpn_id                    = t.vpn-id
    ip                        = t.ip
    udp_port                  = t.port
    community_name            = try(t.community-name, null)
    user                      = try(t.user, null)
    source_interface          = startswith(try(t.source-interface, ""), "DEVICE_VARIABLE;") ? null : t.source-interface
    source_interface_variable = startswith(try(t.source-interface, ""), "DEVICE_VARIABLE;") ? split(";", t.source-interface)[1] : null
  }]
}

resource "sdwan_cisco_system_feature_template" "cisco_system_feature_template" {
  for_each                               = { for t in try(local.cedge_feature_templates.cisco_system, {}) : t.name => t }
  name                                   = each.value.name
  description                            = each.value.description
  device_types                           = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  timezone                               = startswith(try(each.value.parameters.clock.timezone, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.clock.timezone), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.clock.timezone, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.clock.timezone)
  timezone_variable                      = startswith(try(each.value.parameters.clock.timezone, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.clock.timezone), "DEVICE_VARIABLE;") ? split(";", try(each.value.parameters.clock.timezone, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.clock.timezone))[1] : null
  hostname                               = startswith(try(each.value.parameters.host-name, ""), "DEVICE_VARIABLE;") ? null : each.value.parameters.host-name
  hostname_variable                      = startswith(try(each.value.parameters.host-name, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.host-name)[1] : null
  system_description                     = startswith(try(each.value.parameters.description, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.description, null)
  system_description_variable            = startswith(try(each.value.parameters.description, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.description)[1] : null
  location                               = startswith(try(each.value.parameters.location, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.location, null)
  location_variable                      = startswith(try(each.value.parameters.location, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.location)[1] : null
  latitude                               = startswith(try(each.value.parameters.gps-location.latitude, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.gps-location.latitude, null)
  latitude_variable                      = startswith(try(each.value.parameters.gps-location.latitude, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.gps-location.latitude)[1] : null
  longitude                              = startswith(try(each.value.parameters.gps-location.longitude, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.gps-location.longitude, null)
  longitude_variable                     = startswith(try(each.value.parameters.gps-location.longitude, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.gps-location.longitude)[1] : null
  system_ip                              = startswith(try(each.value.parameters.system-ip, ""), "DEVICE_VARIABLE;") ? null : each.value.parameters.system-ip
  system_ip_variable                     = startswith(try(each.value.parameters.system-ip, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.system-ip)[1] : null
  overlay_id                             = try(each.value.parameters.overlay-id, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.overlay-id)
  site_id                                = startswith(try(each.value.parameters.site-id, ""), "DEVICE_VARIABLE;") ? null : each.value.parameters.site-id
  site_id_variable                       = startswith(try(each.value.parameters.site-id, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.site-id)[1] : null
  port_offset                            = startswith(try(each.value.parameters.port-offset, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.port-offset, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.port-offset)
  port_offset_variable                   = startswith(try(each.value.parameters.port-offset, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.port-offset)[1] : null
  region_id                              = startswith(try(each.value.parameters.region-id, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.region-id, null)
  region_id_variable                     = startswith(try(each.value.parameters.region-id, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.region-id)[1] : null
  role                                   = startswith(try(each.value.parameters.role, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.role, null)
  role_variable                          = startswith(try(each.value.parameters.role, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.role)[1] : null
  secondary_region_id                    = startswith(try(each.value.parameters.secondary-region, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.secondary-region, null)
  secondary_region_id_variable           = startswith(try(each.value.parameters.secondary-region, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.secondary-region)[1] : null
  transport_gateway                      = startswith(try(each.value.parameters.transport-gateway, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.transport-gateway, null)
  transport_gateway_variable             = startswith(try(each.value.parameters.transport-gateway, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.transport-gateway)[1] : null
  port_hopping                           = startswith(try(each.value.parameters.port-hop, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.port-hop, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.port-hop)
  port_hopping_variable                  = startswith(try(each.value.parameters.port-hop, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.port-hop)[1] : null
  control_session_pps                    = try(each.value.parameters.control-session-pps, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.control-session-pps)
  track_transport                        = try(each.value.parameters.track-transport, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.track-transport)
  console_baud_rate                      = startswith(try(each.value.parameters.console-baud-rate, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.console-baud-rate, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.console-baud-rate)
  console_baud_rate_variable             = startswith(try(each.value.parameters.console-baud-rate, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.console-baud-rate)[1] : null
  max_omp_sessions                       = try(each.value.parameters.max_omp_sessions, null)
  track_default_gateway                  = try(each.value.parameters.track-default-gateway, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.track-default-gateway)
  admin_tech_on_failure                  = try(each.value.parameters.admin-tech-on-failure, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.admin-tech-on-failure)
  idle_timeout                           = try(each.value.parameters.idle-timeout, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.idle-timeout)
  on_demand_tunnel                       = startswith(try(each.value.parameters.on-demand.enable, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.on-demand.enable, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.on-demand.enable)
  on_demand_tunnel_variable              = startswith(try(each.value.parameters.on-demand.enable, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.on-demand.enable)[1] : null
  on_demand_tunnel_idle_timeout          = startswith(try(each.value.parameters.on-demand.idle-timeout, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.on-demand.idle-timeout, local.defaults.sdwan.cedge_feature_templates.cisco_system.parameters.on-demand.idle-timeout)
  on_demand_tunnel_idle_timeout_variable = startswith(try(each.value.parameters.on-demand.idle-timeout, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.on-demand.idle-timeout)[1] : null

}

resource "sdwan_cisco_vpn_feature_template" "cisco_vpn_feature_template" {
  for_each                     = { for t in try(local.cedge_feature_templates.cisco_vpn, {}) : t.name => t }
  name                         = each.value.name
  description                  = each.value.description
  device_types                 = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  vpn_id                       = each.value.parameters.vpn-id
  vpn_name                     = try(each.value.parameters.name, null)
  omp_admin_distance_ipv4      = try(each.value.parameters.omp-admin-distance-ipv4, null)
  omp_admin_distance_ipv6      = try(each.value.parameters.omp-admin-distance-ipv6, null)
  enhance_ecmp_keying          = startswith(try(each.value.parameters.ecmp-hash-key.layer4, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ecmp-hash-key.layer4, null)
  enhance_ecmp_keying_variable = startswith(try(each.value.parameters.ecmp-hash-key.layer4, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ecmp-hash-key.layer4)[1] : null
  dns_ipv4_servers = try(length(each.value.parameters.dns) == 0, true) ? null : [for d in each.value.parameters.dns : {
    address          = startswith(try(d.dns-addr, ""), "DEVICE_VARIABLE;") ? null : d.dns-addr
    address_variable = startswith(try(d.dns-addr, ""), "DEVICE_VARIABLE;") ? split(";", d.dns-addr)[1] : null
    role             = d.role
  }]
  ipv4_static_routes = try(length(each.value.parameters.ip.route) == 0, true) ? null : [for r in each.value.parameters.ip.route : {
    prefix          = startswith(try(r.prefix, ""), "DEVICE_VARIABLE;") ? null : r.prefix
    prefix_variable = startswith(try(r.prefix, ""), "DEVICE_VARIABLE;") ? split(";", r.prefix)[1] : null
    next_hops = try(length(r.next-hop) == 0, true) ? null : [for n in r.next-hop : {
      address           = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? null : n.address
      address_variable  = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? split(";", n.address)[1] : null
      distance          = startswith(try(n.distance, ""), "DEVICE_VARIABLE;") ? null : try(n.distance, null)
      distance_variable = startswith(try(n.distance, ""), "DEVICE_VARIABLE;") ? split(";", n.distance)[1] : null
    }]
    track_next_hops = try(length(r.next-hop-with-track) == 0, true) ? null : [for n in r.next-hop-with-track : {
      address           = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? null : n.address
      address_variable  = startswith(try(n.address, ""), "DEVICE_VARIABLE;") ? split(";", n.address)[1] : null
      distance          = startswith(try(n.distance, ""), "DEVICE_VARIABLE;") ? null : try(n.distance, null)
      distance_variable = startswith(try(n.distance, ""), "DEVICE_VARIABLE;") ? split(";", n.distance)[1] : null
      tracker           = startswith(try(n.tracker, ""), "DEVICE_VARIABLE;") ? null : try(n.tracker, null)
      tracker_variable  = startswith(try(n.tracker, ""), "DEVICE_VARIABLE;") ? split(";", n.tracker)[1] : null
    }]
    optional = try(r.optional, null)
  }]
  omp_advertise_ipv4_routes = try(length(each.value.parameters.omp.advertise) == 0, true) ? null : [for a in each.value.parameters.omp.advertise : {
    protocol          = a.protocol
    protocol_sub_type = a.protocol == "ospf" && try(a.protocol-sub-type, null) != null ? [a.protocol-sub-type] : null
    route_policy      = try(a.route-policy, null)
  }]
}

resource "sdwan_cisco_vpn_interface_feature_template" "cisco_vpn_interface_feature_template" {
  for_each                       = { for t in try(local.cedge_feature_templates.cisco_vpn_interface, {}) : t.name => t }
  name                           = each.value.name
  description                    = each.value.description
  device_types                   = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  interface_name                 = startswith(try(each.value.parameters.if-name, ""), "DEVICE_VARIABLE;") ? null : each.value.parameters.if-name
  interface_name_variable        = startswith(try(each.value.parameters.if-name, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.if-name)[1] : null
  interface_description          = startswith(try(each.value.parameters.description, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.description, null)
  interface_description_variable = startswith(try(each.value.parameters.description, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.description)[1] : null
  address                        = startswith(try(each.value.parameters.ip.address, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.ip.address, null)
  address_variable               = startswith(try(each.value.parameters.ip.address, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.ip.address)[1] : null
  dhcp                           = try(each.value.parameters.ip.dhcp-client, null)
  dhcp_distance                  = try(each.value.parameters.ip.dhcp-distance, null)
  nat                            = try(each.value.parameters.nat, null) != null ? true : null
  nat_type                       = try(each.value.parameters.nat.nat-choice, null)
  enable_core_region             = try(each.value.parameters.tunnel-interface.enable-core-region, null)
  core_region                    = startswith(try(each.value.parameters.tunnel-interface.core-region, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.core-region, null)
  core_region_variable           = startswith(try(each.value.parameters.tunnel-interface.core-region, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.core-region)[1] : null
  secondary_region               = startswith(try(each.value.parameters.tunnel-interface.secondary-region, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.secondary-region, null)
  secondary_region_variable      = startswith(try(each.value.parameters.tunnel-interface.secondary-region, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.secondary-region)[1] : null
  tunnel_interface_encapsulations = !can(each.value.parameters.tunnel-interface) ? null : (can(each.value.parameters.tunnel-interface.encapsulation) ? [for e in each.value.parameters.tunnel-interface.encapsulation : {
    encapsulation       = e.encap
    preference          = startswith(try(e.preference, ""), "DEVICE_VARIABLE;") ? null : try(e.preference, null)
    preference_variable = startswith(try(e.preference, ""), "DEVICE_VARIABLE;") ? split(";", e.preference)[1] : null
    weight              = startswith(try(e.weight, ""), "DEVICE_VARIABLE;") ? null : try(e.weight, null)
    weight_variable     = startswith(try(e.weight, ""), "DEVICE_VARIABLE;") ? split(";", e.weight)[1] : null
    }] : [{
    encapsulation = local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.encapsulation.encap
  }])
  tunnel_qos_mode                                         = startswith(try(each.value.parameters.tunnel-interface.tunnel-qos.mode, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.tunnel-qos.mode, null)
  tunnel_qos_mode_variable                                = startswith(try(each.value.parameters.tunnel-interface.tunnel-qos.mode, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.tunnel-qos.mode)[1] : null
  tunnel_interface_groups                                 = startswith(try(tostring(each.value.parameters.tunnel-interface.group), ""), "DEVICE_VARIABLE;") ? null : try(tolist(each.value.parameters.tunnel-interface.group), null)
  tunnel_interface_groups_variable                        = startswith(try(tostring(each.value.parameters.tunnel-interface.group), ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.group)[1] : null
  tunnel_interface_color                                  = startswith(try(each.value.parameters.tunnel-interface.color.value, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.color.value, null)
  tunnel_interface_color_variable                         = startswith(try(each.value.parameters.tunnel-interface.color.value, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.color.value)[1] : null
  tunnel_interface_max_control_connections                = startswith(try(each.value.parameters.tunnel-interface.max-control-connections, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.max-control-connections, null)
  tunnel_interface_max_control_connections_variable       = startswith(try(each.value.parameters.tunnel-interface.max-control-connections, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.max-control-connections)[1] : null
  tunnel_interface_vmanage_connection_preference          = startswith(try(each.value.parameters.tunnel-interface.vmanage-connection-preference, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.vmanage-connection-preference, null)
  tunnel_interface_vmanage_connection_preference_variable = startswith(try(each.value.parameters.tunnel-interface.vmanage-connection-preference, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.vmanage-connection-preference)[1] : null
  tunnel_interface_port_hop                               = startswith(try(each.value.parameters.tunnel-interface.port-hop, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.port-hop, null)
  tunnel_interface_port_hop_variable                      = startswith(try(each.value.parameters.tunnel-interface.port-hop, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.port-hop)[1] : null
  tunnel_interface_color_restrict                         = startswith(try(each.value.parameters.tunnel-interface.color.restrict, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.color.restrict, null)
  tunnel_interface_color_restrict_variable                = startswith(try(each.value.parameters.tunnel-interface.color.restrict, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.color.restrict)[1] : null
  tunnel_interface_hello_interval                         = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.hello-interval, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.hello-interval)
  tunnel_interface_hello_tolerance                        = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.hello-tolerance, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.hello-tolerance)
  tunnel_interface_clear_dont_fragment                    = try(each.value.parameters.tunnel-interface, null) == null ? null : startswith(try(each.value.parameters.tunnel-interface.clear-dont-fragment, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tunnel-interface.clear-dont-fragment, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.clear-dont-fragment)
  tunnel_interface_clear_dont_fragment_variable           = startswith(try(each.value.parameters.tunnel-interface.clear-dont-fragment, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tunnel-interface.clear-dont-fragment)[1] : null
  tunnel_interface_allow_all                              = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.all, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.all)
  tunnel_interface_allow_bgp                              = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.bgp, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.bgp)
  tunnel_interface_allow_dhcp                             = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.dhcp, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.dhcp)
  tunnel_interface_allow_dns                              = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.dns, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.dns)
  tunnel_interface_allow_icmp                             = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.icmp, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.icmp)
  tunnel_interface_allow_ssh                              = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.sshd, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.sshd)
  tunnel_interface_allow_netconf                          = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.netconf, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.netconf)
  tunnel_interface_allow_ntp                              = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.ntp, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.ntp)
  tunnel_interface_allow_ospf                             = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.ospf, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.ospf)
  tunnel_interface_allow_stun                             = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.stun, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.stun)
  tunnel_interface_allow_snmp                             = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.snmp, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.snmp)
  tunnel_interface_allow_https                            = try(each.value.parameters.tunnel-interface, null) == null ? null : try(each.value.tunnel-interface.allow-service.https, local.defaults.sdwan.cedge_feature_templates.cisco_vpn_interface.parameters.tunnel-interface.allow-service.https)
  interface_mtu                                           = startswith(try(each.value.parameters.mtu, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.mtu, null)
  interface_mtu_variable                                  = startswith(try(each.value.parameters.mtu, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.mtu)[1] : null
  tloc_extension                                          = startswith(try(each.value.parameters.tloc-extension, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.tloc-extension, null)
  tloc_extension_variable                                 = startswith(try(each.value.parameters.tloc-extension, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.tloc-extension)[1] : null
  shutdown                                                = startswith(try(each.value.parameters.shutdown, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.shutdown, null)
  shutdown_variable                                       = startswith(try(each.value.parameters.shutdown, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.shutdown)[1] : null
  shaping_rate                                            = startswith(try(each.value.parameters.shaping-rate, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.shaping-rate, null)
  shaping_rate_variable                                   = startswith(try(each.value.parameters.shaping-rate, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.shaping-rate)[1] : null
  bandwidth_upstream                                      = startswith(try(each.value.parameters.bandwidth-upstream, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bandwidth-upstream, null)
  bandwidth_upstream_variable                             = startswith(try(each.value.parameters.bandwidth-upstream, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bandwidth-upstream)[1] : null
  bandwidth_downstream                                    = startswith(try(each.value.parameters.bandwidth-downstream, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.bandwidth-downstream, null)
  bandwidth_downstream_variable                           = startswith(try(each.value.parameters.bandwidth-downstream, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.bandwidth-downstream)[1] : null
  ipv4_vrrps = try(length(each.value.parameters.vrrp) == 0, true) ? null : [for v in each.value.parameters.vrrp : {
    group_id                     = startswith(try(v.grp-id, ""), "DEVICE_VARIABLE;") ? null : try(v.grp-id, null)
    group_id_variable            = startswith(try(v.grp-id, ""), "DEVICE_VARIABLE;") ? split(";", v.grp-id)[1] : null
    priority                     = startswith(try(v.priority, ""), "DEVICE_VARIABLE;") ? null : try(v.priority, null)
    priority_variable            = startswith(try(v.priority, ""), "DEVICE_VARIABLE;") ? split(";", v.priority)[1] : null
    timer                        = startswith(try(v.timer, ""), "DEVICE_VARIABLE;") ? null : try(v.timer, null)
    timer_variable               = startswith(try(v.timer, ""), "DEVICE_VARIABLE;") ? split(";", v.timer)[1] : null
    track_omp                    = try(v.track-omp, null)
    track_prefix_list            = try(v.track-prefix-list, null)
    ip_address                   = startswith(try(v.ipv4.address, ""), "DEVICE_VARIABLE;") ? null : try(v.ipv4.address, null)
    ip_address_variable          = startswith(try(v.ipv4.address, ""), "DEVICE_VARIABLE;") ? split(";", v.ipv4.address)[1] : null
    tloc_preference_change       = try(v.tloc-change-pref, null)
    tloc_preference_change_value = try(v.value, null)
  }]
}

resource "sdwan_cli_template_feature_template" "cli_template_feature_template" {
  for_each     = { for t in try(local.cedge_feature_templates.cli-template, {}) : t.name => t }
  name         = each.value.name
  description  = each.value.description
  device_types = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  cli_config   = each.value.parameters.config
}

resource "sdwan_cisco_thousandeyes_feature_template" "cisco_thousandeyes_feature_template" {
  for_each     = { for t in try(local.cedge_feature_templates.cisco_thousandeyes, {}) : t.name => t }
  name         = each.value.name
  description  = each.value.description
  device_types = [for d in try(each.value.deviceType, local.thousand_eyes_device_types) : try(local.device_type_map[d], "vedge-${d}")]
  virtual_applications = try(length(each.value.parameters.virtual-application) == 0, true) ? null : [for va in each.value.parameters.virtual-application : {
    instance_id                     = try(va.instance-id, null)
    application_type                = try(va.application-type, null)
    te_account_group_token          = startswith(try(va.te.token, ""), "DEVICE_VARIABLE;") ? null : try(va.te.token, null)
    te_account_group_token_variable = startswith(try(va.te.token, ""), "DEVICE_VARIABLE;") ? split(";", va.te.token)[1] : null
    te_vpn                          = startswith(try(va.te.vpn, ""), "DEVICE_VARIABLE;") ? null : try(va.te.vpn, null)
    te_vpn_variable                 = startswith(try(va.te.vpn, ""), "DEVICE_VARIABLE;") ? split(";", va.te.vpn)[1] : null
    te_agent_ip                     = startswith(try(va.te.te-mgmt-ip, ""), "DEVICE_VARIABLE;") ? null : try(va.te.te-mgmt-ip, null)
    te_agent_ip_variable            = startswith(try(va.te.te-mgmt-ip, ""), "DEVICE_VARIABLE;") ? split(";", va.te.te-mgmt-ip)[1] : null
    te_default_gateway              = startswith(try(va.te.te-vpg-ip, ""), "DEVICE_VARIABLE;") ? null : try(va.te.te-vpg-ip, null)
    te_default_gateway_variable     = startswith(try(va.te.te-vpg-ip, ""), "DEVICE_VARIABLE;") ? split(";", va.te.te-vpg-ip)[1] : null
    te_name_server                  = startswith(try(va.te.name-server, ""), "DEVICE_VARIABLE;") ? null : try(va.te.name-server, null)
    te_name_server_variable         = startswith(try(va.te.name-server, ""), "DEVICE_VARIABLE;") ? split(";", va.te.name-server)[1] : null
    te_hostname                     = startswith(try(va.te.hostname, ""), "DEVICE_VARIABLE;") ? null : try(va.te.hostname, null)
    te_hostname_variable            = startswith(try(va.te.hostname, ""), "DEVICE_VARIABLE;") ? split(";", va.te.hostname)[1] : null
    te_web_proxy_type               = startswith(try(va.te.proxy_type, ""), "DEVICE_VARIABLE;") ? null : try(va.te.proxy_type, null)
    te_web_proxy_type_variable      = startswith(try(va.te.proxy_type, ""), "DEVICE_VARIABLE;") ? split(";", va.te.proxy_type)[1] : null
    te_proxy_host                   = startswith(try(va.te.proxy_static.proxy_host, ""), "DEVICE_VARIABLE;") ? null : try(va.te.proxy_static.proxy_host, null)
    te_proxy_host_variable          = startswith(try(va.te.proxy_static.proxy_host, ""), "DEVICE_VARIABLE;") ? split(";", va.te.proxy_static.proxy_host)[1] : null
    te_proxy_port                   = startswith(try(va.te.proxy_static.proxy_port, ""), "DEVICE_VARIABLE;") ? null : try(va.te.proxy_static.proxy_port, null)
    te_proxy_port_variable          = startswith(try(va.te.proxy_static.proxy_port, ""), "DEVICE_VARIABLE;") ? split(";", va.te.proxy_static.proxy_port)[1] : null
    te_pac_url                      = startswith(try(va.te.proxy_pac.pac_url, ""), "DEVICE_VARIABLE;") ? null : try(va.te.proxy_pac.pac_url, null)
    te_pac_url_variable             = startswith(try(va.te.proxy_pac.pac_url, ""), "DEVICE_VARIABLE;") ? split(";", va.te.proxy_pac.pac_url)[1] : null
  }]
}

resource "sdwan_cisco_dhcp_server_feature_template" "cisco_dhcp_server_feature_template" {
  for_each                   = { for t in try(local.cedge_feature_templates.cisco_dhcp_server, {}) : t.name => t }
  name                       = each.value.name
  description                = each.value.description
  device_types               = [for d in try(each.value.deviceType, local.device_types) : try(local.device_type_map[d], "vedge-${d}")]
  address_pool               = startswith(try(each.value.parameters.address-pool, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.address-pool, null)
  address_pool_variable      = startswith(try(each.value.parameters.address-pool, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.address-pool)[1] : null
  exclude_addresses          = startswith(try(each.value.parameters.exclude, ""), "DEVICE_VARIABLE;") ? null : try(tolist(each.value.parameters.exclude), null)
  exclude_addresses_variable = startswith(try(each.value.parameters.exclude, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.exclude)[1] : null
  lease_time                 = startswith(try(each.value.parameters.lease-time, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.lease-time, null)
  lease_time_variable        = startswith(try(each.value.parameters.lease-time, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.lease-time)[1] : null
  default_gateway            = startswith(try(each.value.parameters.options.default-gateway, ""), "DEVICE_VARIABLE;") ? null : try(each.value.parameters.options.default-gateway, null)
  default_gateway_variable   = startswith(try(each.value.parameters.options.default-gateway, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.options.default-gateway)[1] : null
  dns_servers                = startswith(try(each.value.parameters.options.dns-servers, ""), "DEVICE_VARIABLE;") ? null : try(tolist(each.value.parameters.options.dns-servers), null)
  dns_servers_variable       = startswith(try(each.value.parameters.options.dns-servers, ""), "DEVICE_VARIABLE;") ? split(";", each.value.parameters.options.dns-servers)[1] : null
  static_leases = try(length(each.value.parameters.static-lease) == 0, true) ? null : [for sl in each.value.parameters.static-lease : {
    mac_address          = startswith(try(sl.mac-address, ""), "DEVICE_VARIABLE;") ? null : try(sl.mac-address, null)
    mac_address_variable = startswith(try(sl.mac-address, ""), "DEVICE_VARIABLE;") ? split(";", sl.mac-address)[1] : null
    ip_address           = startswith(try(sl.ip, ""), "DEVICE_VARIABLE;") ? null : try(sl.ip, null)
    ip_address_variable  = startswith(try(sl.ip, ""), "DEVICE_VARIABLE;") ? split(";", sl.ip)[1] : null
    optional             = try(sl.optional, null)
  }]
}
