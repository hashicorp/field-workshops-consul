variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}

variable "resource_group" {
  default = "hashicorp-instruqt"
}

variable "web_count" {
  default = 1
  description = "initial web servers"
}

variable "app_count" {
  default = 1
  description = "initial app servers"
}

variable "db_count" {
  default = 1
  description = "initial web servers"
}