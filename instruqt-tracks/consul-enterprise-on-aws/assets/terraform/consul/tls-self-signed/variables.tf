variable "ca_validity" {
  type        = number
  description = "Duration, in hours, during which the CA certificate will remain valid"
  default     = 43800
}

variable "server_validity" {
  type        = number
  description = "Duration, in hours, during which the Consul Server certificates will remain valid"
  default     = 8760
}

variable "consul_datacenter" {
  type        = string
  description = "The name of the Consul datacenter to generate TLS certificates for"
}

variable "environment_name" {
  type        = string
  description = "Environment name to prefix resources with"
}

variable "dns_names" {
  type        = list
  description = "dns names for Consul certs"
}
