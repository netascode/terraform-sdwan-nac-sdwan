resource "sdwan_tag" "tag" {
  for_each    = { for tag in distinct(flatten([for router in try(local.routers, []) : router.tags])) : tag => tag }
  name        = each.value
  description = each.value
  devices = [
    for router in local.routers : router.chassis_id if contains(router.tags, each.value)
  ]
}

resource "sdwan_wan_edge_certificate_validate" "wan_edge_certificate_validate" {
  for_each = {
    for router in local.routers :
    router.chassis_id => router
    if try(router.certificate_validity, null) != null
  }
  chassis_number = each.value.chassis_id
  validity       = each.value.certificate_validity
}

resource "sdwan_send_wan_edge_list_to_controllers" "send_wan_edge_list_to_controllers" {
  for_each = try(local.settings.wan_edge_list.send_to_controllers, false) && length(sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate) > 0 ? toset(["send_to_controllers"]) : toset([])
  version  = sum([for certificate in sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate : certificate.version])
}
