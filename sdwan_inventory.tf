resource "sdwan_tag" "tag" {
  # Tags belong to the groups block: one state lists every router that carries a tag name.
  for_each    = { for tag in distinct(flatten([for router in try(local.routers, []) : router.tags])) : tag => tag if local.manage_global }
  name        = each.value
  description = each.value
  devices = [
    for router in local.routers : router.chassis_id if contains(router.tags, each.value)
  ]
}


# Certificate validity of the routers this state deploys: in a split deployment, the state of the
# router's ownership entry. Removing the resource only drops it from state, so a router handed over
# to another state keeps its validity.
resource "sdwan_wan_edge_certificate_validate" "wan_edge_certificate_validate" {
  for_each = {
    for router in local.device_routers : router.chassis_id => router
    if router.certificate_validity != null && !router.handover
  }
  chassis_number = each.value.chassis_id
  validity       = each.value.certificate_validity
}

# Sends SD-WAN Manager's WAN edge list to the controllers. The list is tenant-wide and a push sends
# all of it, whoever changed it, so only the global state pushes (settings are global): when the
# validity it manages changes (version), and on any plan where SD-WAN Manager reports controllers
# out of sync, e.g. after a site/region state changed the validity of its routers. A single state
# pushes only when it manages a validity, as before.
resource "sdwan_send_wan_edge_list_to_controllers" "send_wan_edge_list_to_controllers" {
  for_each = try(local.settings.wan_edge_list.send_to_controllers, false) && (length(sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate) > 0 || length(local.local_definitions) > 0) ? toset(["send_to_controllers"]) : toset([])
  version  = sum(concat([0], [for certificate in sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate : certificate.version]))
}
