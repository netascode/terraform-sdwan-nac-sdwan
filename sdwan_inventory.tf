resource "sdwan_tag" "tag" {
  for_each    = { for tag in distinct(flatten([for router in try(local.routers, []) : router.tags])) : tag => tag }
  name        = each.value
  description = each.value
  devices = [
    for router in local.routers : router.chassis_id if contains(router.tags, each.value)
  ]
}

