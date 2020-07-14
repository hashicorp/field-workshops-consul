variable "endpoint" {}
variable "consulconfig" {}
variable "ca_cert" {}
variable "ssh_public_key" {
  description = "SSH key for the consul instances"
}
variable "consul_token" {}
variable "app_count" {
  default = 2
}
variable "web_count" {
  default = 2
}