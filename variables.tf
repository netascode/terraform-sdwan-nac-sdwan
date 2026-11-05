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

variable "handover_sites" {
  description = "IDs of the sites whose routers this state hands over to another state. Their routers leave the configuration and policy group device resources without being released from their groups (`retain_devices`), so they stay associated and deployed. Set it for the apply that hands them over; in the next change, remove the sites from this state's data and clear the list."
  type        = list(number)
  default     = []
  nullable    = false
}

variable "write_default_values_file" {
  description = "Write all default values to a YAML file. Value is a path pointing to the file to be created."
  type        = string
  default     = ""
}
