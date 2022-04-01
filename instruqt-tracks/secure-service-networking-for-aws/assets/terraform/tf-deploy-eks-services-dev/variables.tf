variable "region" {
  description = "The region of the HCP HVN and Consul cluster."
  type        = string
  default     = "us-west-2"
}

variable "env" {
  description = "eks_dev"
  type        = string
  default     = "workshop-hcp-consul"

}

var "cluster_id" {
  description = ""
  type        = string
  default     = "workshop-hcp-consul"
}
