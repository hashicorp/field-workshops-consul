# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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
variable "hvn_id" {
  description = "The ID of the HCP HVN."
  type        = string
  default     = "workshop-hvn"
}
variable "cluster_id" {
  description = "The ID of the HCP Consul cluster."
  type        = string
  default     = "workshop-hcp-consul"
}
variable "region" {
  description = "The region of the HCP HVN and Consul cluster."
  type        = string
  default     = "us-west-2"
}
variable "cloud_provider" {
  description = "The cloud provider of the HCP HVN and Consul cluster."
  type        = string
  default     = "aws"
}
