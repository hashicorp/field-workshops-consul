variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "consul-ecs"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "consul_acl_token" {
  type        = string
  description = "Your Consul ACL token with __ permissions."
}

variable "consul_gossip_key" {
  type        = string
  description = "Your Consul gossip encryption key."
}

variable "consul_client_ca_path" {
  type        = string
  description = "The path to your Consul CA certificate."
}

variable "default_tags" {
  description = "Default Tags for AWS"
  type        = map(string)
  default = {
    Environment = "consul-ecs"
  }
}
