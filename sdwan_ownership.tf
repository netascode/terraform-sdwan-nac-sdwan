# What this state manages. Every state of a split deployment loads the same data: the global state
# (manage_global) manages everything no entry of var.ownership claims, a site/region state
# (local_set) what its entry claims and the routers of its sites. The rest is emptied here and read
# by name where referenced (sdwan_lookups.tf). References only go from a site/region state to the
# global state; the checks below (outputs.tf) reject claims that would break this.
locals {
  manage_global                = var.manage_global
  model_feature_profiles       = try(local.model.sdwan.feature_profiles, {})
  model_configuration_groups   = try(local.model.sdwan.configuration_groups, [])
  model_policy_groups          = try(local.model.sdwan.policy_groups, [])
  model_policy_object_profile  = try(local.model_feature_profiles.policy_object_profile, {})
  policy_object_profile_fields = ["name", "description"]

  # The entries with every field set. A site item is { raw, from, to } (from and to are null when
  # malformed); the modes are "list" (a list of names), "exclusive" or "none".
  local_definitions = { for key, entry in try(var.ownership.local_definitions, {}) : key => {
    sites = [for item in try(tolist(entry.sites), []) : {
      raw  = tostring(item)
      from = can(regex("^[0-9]+$", tostring(item))) ? tonumber(item) : try(tonumber(regex("^([0-9]+)-([0-9]+)$", tostring(item))[0]), null)
      to   = can(regex("^[0-9]+$", tostring(item))) ? tonumber(item) : try(tonumber(regex("^([0-9]+)-([0-9]+)$", tostring(item))[1]), null)
    }]
    configuration_groups = try([for name in entry.configuration_groups : tostring(name)], [])
    policy_groups        = try([for name in entry.policy_groups : tostring(name)], [])
    profiles_mode        = try(coalesce(tostring(entry.feature_profiles), "list"), "list")
    profile_names        = try([for name in entry.feature_profiles : tostring(name)], [])
    objects_mode         = try(coalesce(tostring(entry.policy_objects), "list"), "list")
    object_names         = try([for name in entry.policy_objects : tostring(name)], [])
  } }
  # This state's entry key, or "" (unclaimed items have the owner "").
  local_set_key = var.local_set == null ? "" : var.local_set

  # Group name => entries that claim it, and => its owner ("" for the global state).
  configuration_group_claims = { for c in flatten([for key, e in local.local_definitions : [for name in e.configuration_groups : { key = key, name = name }]]) : c.name => c.key... }
  policy_group_claims        = { for c in flatten([for key, e in local.local_definitions : [for name in e.policy_groups : { key = key, name = name }]]) : c.name => c.key... }
  configuration_group_owner  = { for g in local.model_configuration_groups : g.name => try(local.configuration_group_claims[g.name][0], "") }
  policy_group_owner         = { for g in local.model_policy_groups : g.name => try(local.policy_group_claims[g.name][0], "") }

  # Profile type => profile name => owners of the groups that use it.
  profile_users = merge(
    { for key, type in local.configuration_group_profile_types : type => {
      for p in try(local.model_feature_profiles[type], []) : p.name => [
        for g in local.model_configuration_groups : local.configuration_group_owner[g.name] if try(g[key], null) == p.name
      ]
    } },
    { for key, type in local.policy_group_profile_types : type => {
      for p in try(local.model_feature_profiles[type], []) : p.name => [
        for g in local.model_policy_groups : local.policy_group_owner[g.name] if try(g[key], null) == p.name
      ]
    } },
  )
  # "exclusive" claims the profiles that only the entry's groups use; a list claims those names.
  # Topology profiles and the policy object profile can't be claimed.
  profile_claims = flatten([for key, e in local.local_definitions : [
    for type, users in local.profile_users : [
      for name, owners in users : { key = key, id = "${type}/${name}" }
      if e.profiles_mode == "exclusive" ? length(owners) > 0 && alltrue([for o in owners : o == key]) : contains(e.profile_names, name)
    ]
  ]])
  profile_claim_keys = { for c in local.profile_claims : c.id => c.key... }
  profile_owner      = { for id, keys in local.profile_claim_keys : id => keys[0] }

  # A profile uses an object when the object's name appears as a string value in the profile's data;
  # a false match only keeps an object global.
  policy_objects_all = flatten([
    for type, objects in local.model_policy_object_profile : [
      for o in objects : { id = "${type}/${o.name}", name = o.name, json = jsonencode(o) }
    ] if !contains(local.policy_object_profile_fields, type)
  ])
  policy_object_users = flatten([
    for type, profiles in local.model_feature_profiles : [
      for p in profiles : { owner = lookup(local.profile_owner, "${type}/${p.name}", ""), json = jsonencode(p) }
    ] if type != "policy_object_profile"
  ])
  policy_object_user_owners = { for o in local.policy_objects_all : o.id => [for u in local.policy_object_users : u.owner if strcontains(u.json, jsonencode(o.name))] }
  # Objects that use, or are used by, another object: these stay global.
  policy_object_linked = { for o in local.policy_objects_all : o.id => length([
    for other in local.policy_objects_all : other if other.id != o.id && (strcontains(other.json, jsonencode(o.name)) || strcontains(o.json, jsonencode(other.name)))
  ]) > 0 }
  # "exclusive" claims the unlinked objects that only the entry's profiles use; a list claims those names.
  policy_object_claims = flatten([for key, e in local.local_definitions : [
    for o in local.policy_objects_all : { key = key, id = o.id }
    if e.objects_mode == "exclusive" ? length(local.policy_object_user_owners[o.id]) > 0 && alltrue([for owner in local.policy_object_user_owners[o.id] : owner == key]) && !local.policy_object_linked[o.id] : contains(e.object_names, o.name)
  ]])
  policy_object_claim_keys = { for c in local.policy_object_claims : c.id => c.key... }
  policy_object_owner      = { for id, keys in local.policy_object_claim_keys : id => keys[0] }

  # What this state manages: an unclaimed item with manage_global, a claimed one with its entry.
  owned_configuration_groups = [
    for g in local.model_configuration_groups : g
    if local.configuration_group_owner[g.name] == "" ? local.manage_global : local.configuration_group_owner[g.name] == local.local_set_key
  ]
  owned_policy_groups = [
    for g in local.model_policy_groups : g
    if local.policy_group_owner[g.name] == "" ? local.manage_global : local.policy_group_owner[g.name] == local.local_set_key
  ]
  owned_feature_profiles = merge(
    { for type, profiles in local.model_feature_profiles : type => [
      for p in profiles : p
      if lookup(local.profile_owner, "${type}/${p.name}", "") == "" ? local.manage_global : lookup(local.profile_owner, "${type}/${p.name}", "") == local.local_set_key
    ] if type != "policy_object_profile" },
    { for k, v in { policy_object_profile = merge(local.model_policy_object_profile, {
      for type, objects in local.model_policy_object_profile : type => [
        for o in objects : o
        if lookup(local.policy_object_owner, "${type}/${o.name}", "") == "" ? local.manage_global : lookup(local.policy_object_owner, "${type}/${o.name}", "") == local.local_set_key
      ] if !contains(local.policy_object_profile_fields, type)
    }) } : k => v if contains(keys(local.model_feature_profiles), "policy_object_profile") && (local.manage_global || length(local.owned_local_policy_objects) > 0) },
  )
  owned_local_policy_objects = [for id, owner in local.policy_object_owner : id if owner == local.local_set_key]
  # Whether this state manages claimed groups, profiles or objects.
  owns_local_definitions = local.local_set_key != "" && contains(concat(
    values(local.configuration_group_owner), values(local.policy_group_owner), values(local.profile_owner), values(local.policy_object_owner),
  ), local.local_set_key)
  # Whether this state manages claimed feature profiles: only they reference policy objects.
  owns_local_profiles = local.local_set_key != "" && contains(values(local.profile_owner), local.local_set_key)
  # Policy objects this state's profiles use but another state manages (a false match only adds a
  # lookup).
  policy_object_lookup_names = local.manage_global || !local.owns_local_profiles ? [] : distinct([
    for o in local.policy_objects_all : o.name
    if lookup(local.policy_object_owner, o.id, "") != local.local_set_key && contains(local.policy_object_user_owners[o.id], local.local_set_key)
  ])

  # The entry of each router: through its site, or a claimed configuration or policy group. "" for
  # none; more than one fails the plan.
  site_ids = [for site in local.sites : site.id]
  entry_selected_sites = { for key, e in local.local_definitions : key => [
    for id in local.site_ids : id if anytrue([for s in e.sites : try(id >= s.from && id <= s.to, false)])
  ] }
  router_entries = { for router in local.routers : router.chassis_id => distinct(compact(concat(
    [for key, ids in local.entry_selected_sites : key if contains(ids, router.site_id)],
    [try(local.configuration_group_owner[router.configuration_group], "")],
    [try(local.policy_group_owner[router.policy_group], "")],
  ))) }
  router_entry = { for id, keys in local.router_entries : id => length(keys) == 1 ? keys[0] : "" }

  # Routers of the group device resources: those of this state's entry, or in the global state those
  # outside the entries, plus the routers of handover_sites (retain_devices). Classic attachments
  # stay in the global state.
  device_routers = [
    for router in local.routers : router
    if(local.router_entry[router.chassis_id] == "" ? local.manage_global : local.router_entry[router.chassis_id] == local.local_set_key) || router.handover
  ]
  device_site_ids = distinct([for router in local.device_routers : router.site_id])
}

# Ownership checks (outputs.tf): computed from the whole data, so every state gives the same answer.
locals {
  profile_user_owners = merge([for type, users in local.profile_users : { for name, owners in users : "${type}/${name}" => owners }]...)
  ownership_bad_modes = [for key, e in local.local_definitions : key if !contains(["list", "exclusive", "none"], e.profiles_mode) || !contains(["list", "exclusive", "none"], e.objects_mode)]
  # A site item is an ID or "from-to" with from <= to; a single ID must be in the data (a range may
  # select no site yet); a site may be selected by one entry only.
  ownership_bad_sites       = flatten([for key, e in local.local_definitions : [for s in e.sites : "${s.raw} (${key})" if !try(s.from <= s.to, false)]])
  ownership_unknown_sites   = flatten([for key, e in local.local_definitions : [for s in e.sites : s.raw if s.from != null && s.from == s.to && !contains(local.site_ids, coalesce(s.from, -1))]])
  ownership_duplicate_sites = [for id in local.site_ids : "${id} (${join(", ", [for key, ids in local.entry_selected_sites : key if contains(ids, id)])})" if length([for key, ids in local.entry_selected_sites : key if contains(ids, id)]) > 1]
  ownership_unknown_items = concat(
    [for name in keys(local.configuration_group_claims) : "configuration group ${name}" if !contains(keys(local.configuration_group_owner), name)],
    [for name in keys(local.policy_group_claims) : "policy group ${name}" if !contains(keys(local.policy_group_owner), name)],
    flatten([for key, e in local.local_definitions : [
      for name in e.profile_names : "feature profile ${name} (${key})" if !contains([for id in keys(local.profile_user_owners) : split("/", id)[1]], name)
    ]]),
    flatten([for key, e in local.local_definitions : [
      for name in e.object_names : "policy object ${name} (${key})" if !contains([for o in local.policy_objects_all : o.name], name)
    ]]),
  )
  ownership_duplicate_claims = concat(
    [for name, keys in local.configuration_group_claims : "configuration group ${name} (${join(", ", keys)})" if length(keys) > 1],
    [for name, keys in local.policy_group_claims : "policy group ${name} (${join(", ", keys)})" if length(keys) > 1],
    [for id, keys in local.profile_claim_keys : "feature profile ${id} (${join(", ", keys)})" if length(keys) > 1],
    [for id, keys in local.policy_object_claim_keys : "policy object ${id} (${join(", ", keys)})" if length(keys) > 1],
  )
  # A router may belong to one entry only: through its site, its configuration group or its policy group.
  ownership_router_conflicts = [
    for r in local.routers : "${r.chassis_id} (site ${r.site_id}): ${join(", ", local.router_entries[r.chassis_id])}"
    if length(local.router_entries[r.chassis_id]) > 1
  ]
  # A claimed profile may only be used by groups of its entry, a claimed object only by profiles of
  # its entry, and a claimed object can't use or be used by another object.
  ownership_used_elsewhere = concat(
    [for id, owner in local.profile_owner : "feature profile ${id} (${owner}) is used by ${join(", ", distinct([for o in local.profile_user_owners[id] : o == "" ? "a global group" : "a group of ${o}" if o != owner]))}"
    if length([for o in local.profile_user_owners[id] : o if o != owner]) > 0],
    [for id, owner in local.policy_object_owner : "policy object ${id} (${owner}) is used by ${join(", ", distinct([for o in local.policy_object_user_owners[id] : o == "" ? "a global profile" : "a profile of ${o}" if o != owner]))}"
    if length([for o in local.policy_object_user_owners[id] : o if o != owner]) > 0],
    [for id, owner in local.policy_object_owner : "policy object ${id} (${owner}) uses or is used by another policy object" if local.policy_object_linked[id]],
  )
  # Scopes are global RBAC: what they list must be managed by the global state.
  ownership_scope_refs = flatten([for s in try(local.model.sdwan.scopes, []) : concat(
    [for name in try(s.configuration_groups, []) : "scope ${s.name} lists configuration group ${name} (${local.configuration_group_owner[name]})" if lookup(local.configuration_group_owner, name, "") != ""],
    [for name in try(s.feature_profiles, []) : "scope ${s.name} lists feature profile ${name} (${join(", ", distinct([for id, owner in local.profile_owner : owner if split("/", id)[1] == name]))})"
    if length([for id, owner in local.profile_owner : id if split("/", id)[1] == name]) > 0],
  )])
}
