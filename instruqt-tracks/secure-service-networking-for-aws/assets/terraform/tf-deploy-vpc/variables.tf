# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## Globals

variable "region" {
  description = "The region of the HCP HVN and Consul cluster."
  type        = string
  default     = "us-west-2"
}

variable "azs" {
  description = "AWS Availabily Zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "route_id" {
  description = "The ID of the HCP HVN route."
  type        = string
  default     = "workshop-hvn-route"
}




## HCP Credentials

variable "hcp_client_id" {
  description = "The ID of the HCP principal."
  type        = string
  default     = ""
}
variable "hcp_client_secret" {
  description = "The Secret of the HCP principal."
  type        = string
  default     = ""
}




## EKS Dev VPC

variable "eks_dev_vpc_name" {
  description = "value"
  type = string
  default = "vpc_eks_dev"
}

variable "eks_dev_vpc_cidr" {
  description = "value"
  type = string
  default = "10.0.0.0/16"
}

variable "eks_dev_private_subnets" {
  description = "EKS Dev VPC Private Subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "eks_dev_public_subnets" {
  description = "EKS Dev VPC Public Subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}




## EKS Prod VPC

variable "eks_prod_vpc_name" {
  description = "value"
  type = string
  default = "vpc_eks_prod"
}

variable "eks_prod_vpc_cidr" {
  description = "value"
  type = string
  default = "10.1.0.0/16"
}

variable "eks_prod_private_subnets" {
  description = "EKS Prod VPC Private Subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "eks_prod_public_subnets" {
  description = "EKS Prod VPC Public Subnets"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}




## ECS Dev VPC

variable "ecs_dev_vpc_name" {
  description = "value"
  type = string
  default = "vpc_ecs_dev"
}

variable "ecs_dev_vpc_cidr" {
  description = "value"
  type = string
  default = "10.2.0.0/16"
}

variable "ecs_dev_private_subnets" {
  description = "ECS Dev VPC Private Subnets"
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
}

variable "ecs_dev_public_subnets" {
  description = "ECS Dev VPC Public Subnets"
  type        = list(string)
  default     = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
}