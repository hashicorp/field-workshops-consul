variable "region" {
  description = "The region of the HCP HVN and Consul cluster."
  type        = string
  default     = "us-west-2"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "eks_dev"

}

variable "cluster_id" {
  description = ""
  type        = string
  default     = "workshop-hcp-consul"
}
