variable "consul_nodes" {
  description = "number of Consul instances"
}

variable "consul_cluster_version" {
  description = "Custom version tag for upgrade migrations"
}

variable "bootstrap" {
  type        = bool
  description = "Initial bootstrap configurations"
}

variable "extra_config" {
  description = "HCL Object with additional configuration overrides supplied to the consul servers."
  default     = {}
}

variable "network_segments" {
  description = "Name and port mapping for segment"
  type        = map
  default     = {}
}
