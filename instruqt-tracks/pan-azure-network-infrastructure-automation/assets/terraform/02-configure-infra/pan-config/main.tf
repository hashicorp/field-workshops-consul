data "terraform_remote_state" "deploy-infra" {
  backend = "local"

  config = {
    path = "../01-deploy-infra/terraform.tfstate"
  }
}

#Virtual router

resource "panos_virtual_router" "vr1" {
  vsys = "vsys1"
  name = "vr1"
  static_dist = 15
  interfaces = [
    panos_ethernet_interface.ethernet1_1.name,
    panos_ethernet_interface.ethernet1_2.name
  ]
}


resource "panos_static_route_ipv4" "default_route" {
  name           = "default"
  virtual_router = panos_virtual_router.vr1.name
  destination    = "0.0.0.0/0"
  next_hop       = "10.1.0.1"
  interface      = panos_ethernet_interface.ethernet1_1.name
}

#route to web and db network 
resource "panos_static_route_ipv4" "web_route" {
  name           = "web_route"
  virtual_router = panos_virtual_router.vr1.name
  destination    = "10.3.0.0/16"
  next_hop       = "10.1.1.1"
  interface      = panos_ethernet_interface.ethernet1_2.name
}

#route to shared network 
resource "panos_static_route_ipv4" "shared_route" {
  name           = "shared_route"
  virtual_router = panos_virtual_router.vr1.name
  destination    = "10.2.0.0/16"
  next_hop       = "10.1.1.1"
  interface      = panos_ethernet_interface.ethernet1_2.name
}


# Management interface profile

resource "panos_management_profile" "allow_ping_mgmt_profile" {
  name = "allow-ping"
  ping = true
}


# public

resource "panos_ethernet_interface" "ethernet1_1" {
  vsys               = "vsys1"
  name               = "ethernet1/1"
  mode               = "layer3"
  enable_dhcp        = true
  management_profile = "allow-ping"
  comment            = "public interface"
  depends_on         = [panos_management_profile.allow_ping_mgmt_profile]
}



resource "panos_zone" "public_zone" {
  name           = "public"
  mode           = "layer3"
  interfaces     = ["${panos_ethernet_interface.ethernet1_1.name}"]
  enable_user_id = true
}


# Private

resource "panos_ethernet_interface" "ethernet1_2" {
  vsys               = "vsys1"
  name               = "ethernet1/2"
  mode               = "layer3"
  enable_dhcp        = true
  management_profile = "allow-ping"
  comment            = "private interface"
  depends_on         = [panos_management_profile.allow_ping_mgmt_profile]
}

resource "panos_zone" "private_zone" {
  name           = "private"
  mode           = "layer3"
  interfaces     = ["${panos_ethernet_interface.ethernet1_2.name}"]
  enable_user_id = true
}
