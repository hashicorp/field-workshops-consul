///////////////////
// Cloud Provider
///////////////////
variable "region" {
  type        = string
  description = "The Azure region to deploy resources to"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy supported resources to. Only works in select regions."
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "Prefix used in resource names"
  default     = "hashicorp"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet in which resources should be deployed"
}

variable "instance_username" {
  type        = string
  description = "Default username to add to VMSS instances"
  default     = "azure-user"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key to use when authenticating to VM instances."
}

variable "owner" {
  type        = string
  description = "value of owner tag on VM instances"
}

variable "ttl" {
  type        = string
  description = "value of ttl tag on VM instances"
}

variable "image_prefix" {
  type        = string
  description = "Prefix of the VM image name (From Packer) to launch in each VMSS"
  default     = "is-azure-immutable-vault-"
}

variable "image_resource_group" {
  type        = string
  description = "Name of the Resource Group where the VM image exists"
}

variable "vm_managed_disk_type" {
  type        = string
  description = "Managed disk type to use for VM instances. Must be one of Standard_LRS, StandardSSD_LRS, or Premium_LRS"
  default     = "Premium_LRS"
}

variable "use_cloud_init" {
  type        = bool
  description = "Whether cloud-init should be used for instance bootstrapping. If false, VM Extensions will be used."
  default     = false
}

variable "storage_account_type" {
  type        = string
  description = "Redundancy type for the Consul Snapshot storage account. Must be one of LRS, GRS, or RAGRS "
  default     = "GRS"
}

///////////////////
// Consul Cluster
///////////////////

variable "consul_cluster_version" {
  type        = string
  description = "Custom version tag for upgrade migrations"
  default     = "0.0.1"
}

variable "consul_vm_size" {
  type        = string
  description = "The size of VM instance to use for Consul server instances"
  default     = "Standard_D2s_v3"
}

variable "redundancy_zones" {
  type        = bool
  description = "Leverage Redundancy Zones within Consul for additional non-voting nodes."
  default     = false
}

variable "consul_nodes" {
  type        = number
  description = "Number of Consul instances"
  default     = 5
}

variable "bootstrap" {
  type        = bool
  description = "Whether cluster should be deployed in bootstrap configuration"
  default     = true
}

variable "enable_connect" {
  type        = bool
  description = "Whether Consul Connect should be enabled on the cluster"
  default     = false
}