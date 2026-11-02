resource "sdwan_wan_edge_certificate_validate" "wan_edge_certificate_validate" {
  for_each = {
    for router in flatten([for site in local.sites : site.routers]) :
    router.chassis_id => router
    if try(router.certificate_validate_state, null) != null
  }
  chassis_number = each.value.chassis_id
  validity       = each.value.certificate_validate_state
}

resource "sdwan_send_wan_edge_list_to_controllers" "send_wan_edge_list_to_controllers" {
  for_each = local.sdwan.send_to_controllers && length(sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate) > 0 ? toset(["send_to_controllers"]) : toset([])
  version  = sum([for certificate in sdwan_wan_edge_certificate_validate.wan_edge_certificate_validate : certificate.version])
}
