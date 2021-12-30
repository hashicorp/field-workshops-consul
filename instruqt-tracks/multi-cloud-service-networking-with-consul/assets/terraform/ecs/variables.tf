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

variable "vpc_id" {
  type        = string
  description = "Your AWS VPC ID."
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

variable "private_subnets_ids" {
  type        = list(string)
  description = "A list of private subnets and their respective ids."
}

variable "public_subnets_ids" {
  type        = list(string)
  description = "A list of public subnets and their respective ids."
}

variable "consul_cluster_addrs" {
  type        = list(string)
  description = "The IP addresses of your Consul cluster. This must be a full URL https://consul.example.com:8501."
}

variable "consul_datacenter" {
  type        = string
  description = "The name of your Consul datacenter."
  default     = "dc1"
}

variable "default_tags" {
  description = "Default Tags for AWS"
  type        = map(string)
  default = {
    Environment = "consul-ecs"
  }
}
