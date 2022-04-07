variable "name" {
  description = "Name to be used on all the resources as identifier."
  type        = string
  default     = "consul-ecs"
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-west-2"
}

variable "consul_client_ca_path" {
  type        = string
  description = "The path to your Consul CA certificate."
  default = "/root/config/hcp_ca.pem"
}

variable "user_public_ip" {
  description = "Your Public IP. This is used in the load balancer security groups to ensure only you can access the Consul UI and example application."
  type        = string
  default     = "0.0.0.0/0"
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