variable "yaml_directories" {
  description = "List of paths to YAML directories."
  type        = list(string)
  default     = []
}

variable "yaml_files" {
  description = "List of paths to YAML files."
  type        = list(string)
  default     = []
}

variable "model" {
  description = "As an alternative to YAML files, a native Terraform data structure can be provided as well."
  type        = map(any)
  default     = {}
}

variable "manage_global" {
  description = "Manage everything that no entry of `ownership` claims: settings, network hierarchy, custom applications, the policy object profile and its objects, feature profiles and their features, configuration and policy groups, tags, topology, scopes and classic (feature and device templates, their attachments and classic policies), and deploy every router that belongs to no entry. `true` for a single state and for the global state of a split deployment; `false` for a site/region state, which manages only what its `local_set` entry claims and reads the rest from SD-WAN Manager by name."
  type        = bool
  default     = true
  nullable    = false
}

variable "local_set" {
  description = "Key of this state's entry in `ownership.local_definitions`, for a site/region state (`manage_global = false`). The state manages the routers of the entry's `sites` and the groups, feature profiles and policy objects the entry claims."
  type        = string
  default     = null
}

variable "ownership" {
  description = "Which site/region state manages what, for a deployment split across several states that load the same data. Pass the same value to every state (e.g. `yamldecode(file(\"../ownership.yaml\"))`). `local_definitions` maps an entry key to `sites` (site IDs and `from-to` ranges, matched against the sites in the data), `configuration_groups` and `policy_groups` (names), `feature_profiles` and `policy_objects` (a list of names, `exclusive` for those only the entry uses, or `none`, the default). A claimed configuration or policy group brings its routers to the entry; a router can belong to one entry only. Anything not claimed, and every router outside the entries, is managed by the global state. A scope can't list a claimed item. `null` for a single state."
  type        = any
  default     = null
}

variable "handover_sites" {
  description = "IDs of the sites whose routers this state hands over to another state. Their routers leave the configuration and policy group device resources without being released from their groups (`retain_devices`), so they stay associated and deployed. Set it in the change that moves the sites to another state, and clear it in the next change."
  type        = list(number)
  default     = []
  nullable    = false
}

variable "write_only_secrets" {
  description = "Send every supported secret through the provider's write-only `<attr>_wo` / `<attr>_wo_version` attributes so it is never stored in Terraform state. Each secret's version defaults to 1; set `<key>_version` next to a secret in the data model and increment it to rotate that secret. When false, only secrets with a `<key>_version` are write-only. Requires Terraform >= 1.11."
  type        = bool
  default     = false
}

variable "write_default_values_file" {
  description = "Write all default values to a YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}
