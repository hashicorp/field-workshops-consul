variable "location" {
  description = "The Azure region to use."
  default     = "East US"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group to create. If not provided, it will be auto-generated."
  default     = ""
  type        = string
}

variable "name_prefix" {
  description = "A prefix for all the names of the created Azure objects. It can end with a dash `-` character, if your naming convention prefers such separator."
  default     = "pantf"
  type        = string
}
variable "owner" {

}
variable "web_subnet" {

}

variable "web_count" {
}
variable "consul_server_ip" {}
variable "web-id" {
  
}
variable "app-lb" {
  
}