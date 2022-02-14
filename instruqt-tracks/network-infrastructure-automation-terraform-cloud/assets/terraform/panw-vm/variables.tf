variable "resource_group_name" {
  default = "vvrg12"
}
variable "location" {
  default = "centralus"
}

variable "FirewallDnsName" {
  default = "pan-fw"
}

variable "WebServerDnsName" {
  default = "pan-web"
}

variable "FromGatewayLogin" {
  default = "0.0.0.0/0"
}
variable "IPAddressDmzNetwork" {
  default = "10.3.3.5"
}
variable "IPAddressAppNetwork" {
  default = "10.3.4.5"
}
variable "IPAddressMgmtNetwork" {
  default = "10.3.1.5"
}
variable "IPAddressInternetNetwork" {
  default = "10.3.2.5"
}

variable "routeTableWeb" {
  default = "Web-to-FW"
}

variable "routeTableDB" {
  default = "DB-to-FW"
}

variable "routeTableTrust" {
  default = "Trust-to-intranetwork"
}

# Note internally there is an assumption
# for the two NSG to have the same name!

variable "fwSku" {
  default = "bundle1"
}

variable "fwOffer" {
  default = "vmseries1"
}

variable "fwPublisher" {
  default = "paloaltonetworks"
}

variable "adminUsername" {
  default = "paloalto"
}

variable "web-vm-name" {
  default = "webserver-vm"
}

variable "db-vm-name" {
  default = "database-vm"
}

variable "gvmSize" {
  default = "Standard_A1"
}

variable "imagePublisher" {
  default = "Canonical"
}

variable "imageOffer" {
  default = "UbuntuServer"
}

variable "ubuntuOSVersion" {
  default = "16.04-LTS"
}
