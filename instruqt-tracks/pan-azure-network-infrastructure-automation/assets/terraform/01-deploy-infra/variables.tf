variable "location" {
  description = "The Azure region to use."
  default     = "East US"
  type        = string
}

variable "owner" {
  description = "Owner"
  type        = string
  default = "azurepan@consulterraformsync.com"
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  type        = string
  default = "hashicorp-pan-consul-nia"
}
