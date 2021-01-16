variable "endpoint" {}
variable "consulconfig" {}
variable "ca_cert" {}
variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}
variable "consul_token" {}
variable "app_count" {
  default = 1
}
variable "web_count" {
  default = 1
}
variable "bigip_mgmt_addr" {}
variable "bigip_admin_user" {}
variable "bigip_admin_passwd" {}
variable "panos_mgmt_addr" {}
variable "panos_username" {}
variable "panos_password" {}
variable "vip_internal_address" {}
