variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}
variable "app_count" {
  default = 1
}
variable "web_count" {
  default = 1
}
variable "bigip_mgmt_addr" {}
variable "bigip_admin_user" {}
variable "vault_addr" {}
variable "panos_mgmt_addr" {}
variable "panos_username" {}
variable "vault_token" {}
variable "vip_internal_address" {}
variable "consul_server_ip" {}
