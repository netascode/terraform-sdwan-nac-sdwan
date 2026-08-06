resource "sdwan_custom_application" "custom_application" {
  for_each           = { for app in try(local.application_catalog.custom_applications, []) : app.name => app }
  app_name           = each.value.name
  application_family = try(each.value.application_family, null)
  application_group  = try(each.value.application_group, null)
  business_relevance = try(each.value.business_relevance, null)
  l3l4 = try(length(each.value.l3l4) > 0, false) ? [
    for item in each.value.l3l4 : {
      ip_addresses = try(item.ip_addresses, null)
      l4_protocol  = try(item.l4_protocol, null)
      ports        = try(item.ports, null)
    }
  ] : null
  server_names  = try(each.value.server_names, null)
  traffic_class = try(each.value.traffic_class, null)
}
