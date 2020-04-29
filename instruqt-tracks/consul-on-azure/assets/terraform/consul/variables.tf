variable "location" {
  description = "location to deploy Consul"
  default     = "eastus"
}

variable "image_resource_group" {
  description = "SSH key for the consul instances"
}

variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}

variable "consul_cluster_version" {
  description = "Custom version tag for upgrade migrations"
}

variable "bootstrap" {
  type        = boolean
  description = "Provision in a bootstrap configuration"
}
