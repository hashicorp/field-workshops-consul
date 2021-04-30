variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}
variable "app_count" {
  default = 2
}
variable "web_count" {
  default = 2
}
variable "bigip_mgmt_addr" {}
variable "vip_internal_address" {}
variable "consul_server_ip" {}
