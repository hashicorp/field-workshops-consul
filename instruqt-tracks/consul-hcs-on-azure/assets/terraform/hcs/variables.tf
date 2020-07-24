variable "managed_resource_group" {
  default = "mrg-hcs-instruqt"
}

variable "accept_marketplace_aggrement" {
  default = 1
}

variable "remote_state" {
  default = "/root/terraform"
}

variable "consul_version" {
  default = "v1.7.2"
}