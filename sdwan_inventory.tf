resource "sdwan_tag" "tag" {
  # Tags belong to the groups block: one state lists every router that carries a tag name.
  for_each    = { for tag in distinct(flatten([for router in try(local.routers, []) : router.tags])) : tag => tag if local.manage_global }
  name        = each.value
  description = each.value
  devices = [
    for router in local.routers : router.chassis_id if contains(router.tags, each.value)
  ]
}

