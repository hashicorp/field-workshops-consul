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

variable "consul_cluster_addr" {
  type        = string
  description = "The network address of your Consul cluster. "
}

variable "consul_datacenter" {
  type        = string
  description = "The name of your Consul datacenter."
  default     = "dc1"
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

variable "vpc_id" {
  type        = string
  description = "Your AWS VPC ID."
}

variable "user_public_ip" {
  description = "Your Public IP. This is used in the load balancer security groups to ensure only you can access the Consul UI and example application."
  type        = string
}

variable "default_tags" {
  description = "Default Tags for AWS"
  type        = map(string)
  default = {
    Environment = "dev"
    Team        = "Education-Consul"
    tutorial    = "Serverless Consul service mesh with ECS and HCP"
  }
}