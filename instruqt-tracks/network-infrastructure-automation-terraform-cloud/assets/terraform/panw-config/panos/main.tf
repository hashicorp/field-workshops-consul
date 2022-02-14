# Virtual router

resource "panos_virtual_router" "vr1" {
  vsys = "vsys1"
  name = "vr1"
  interfaces = [
    panos_ethernet_interface.ethernet1_1.name,
    panos_ethernet_interface.ethernet1_2.name,
    panos_ethernet_interface.ethernet1_3.name
  ]
}

resource "panos_static_route_ipv4" "default_route" {
  name           = "default"
  virtual_router = panos_virtual_router.vr1.name
  destination    = "0.0.0.0/0"
  next_hop       = "10.3.2.1"
  interface      = panos_ethernet_interface.ethernet1_1.name
}

# Service Object for port 9090

resource "panos_service_object" "service-9090" {
    name = "service-9090"
    vsys = "vsys1"
    protocol = "tcp"
    destination_port = "9090"
}

# Management interface profile

resource "panos_management_profile" "allow_ping_mgmt_profile" {
  name = "allow-ping"
  ping = true
}


# Internet

resource "panos_ethernet_interface" "ethernet1_1" {
  vsys               = "vsys1"
  name               = "ethernet1/1"
  mode               = "layer3"
  enable_dhcp        = true
  management_profile = "allow-ping"
  comment            = "Internet interface"
  depends_on         = [panos_management_profile.allow_ping_mgmt_profile]
}

resource "panos_zone" "internet_zone" {
  name = "Internet"
  mode = "layer3"
}

resource "panos_zone_entry" "internet_zone_ethernet1_1" {
  zone      = panos_zone.internet_zone.name
  mode      = panos_zone.internet_zone.mode
  interface = panos_ethernet_interface.ethernet1_1.name
}


# DMZ

resource "panos_ethernet_interface" "ethernet1_2" {
  vsys               = "vsys1"
  name               = "ethernet1/2"
  mode               = "layer3"
  enable_dhcp        = true
  management_profile = "allow-ping"
  comment            = "DMZ interface"
  depends_on         = [panos_management_profile.allow_ping_mgmt_profile]
}

resource "panos_zone" "dmz_zone" {
  name = "DMZ"
  mode = "layer3"
}

resource "panos_zone_entry" "dmz_zone_ethernet1_2" {
  zone      = panos_zone.dmz_zone.name
  mode      = panos_zone.dmz_zone.mode
  interface = panos_ethernet_interface.ethernet1_2.name
}


# Application

resource "panos_ethernet_interface" "ethernet1_3" {
  vsys               = "vsys1"
  name               = "ethernet1/3"
  mode               = "layer3"
  enable_dhcp        = true
  management_profile = "allow-ping"
  comment            = "Application interface"
  depends_on         = [panos_management_profile.allow_ping_mgmt_profile]
}

resource "panos_zone" "app_zone" {
  name = "Application"
  mode = "layer3"
}

resource "panos_zone_entry" "app_zone_ethernet1_3" {
  zone      = panos_zone.app_zone.name
  mode      = panos_zone.app_zone.mode
  interface = panos_ethernet_interface.ethernet1_3.name
}

# Dynamic Address Group
resource "panos_address_group" "cts-addr-grp-web" {
    name = "cts-addr-grp-web"
    description = "Consul Web Servers"
    dynamic_match = "web"
#    dynamic_match = "'web' and 'app'"  # Example of multi-tag
}

# NAT Rule

resource "panos_nat_rule_group" "app" {
  rule {
    name = "web_app"
    original_packet {
      source_zones          = ["Internet"]
      destination_zone      = "Internet"
      source_addresses      = ["any"]
      destination_addresses = ["10.3.2.5"]
    }
    translated_packet {
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = panos_ethernet_interface.ethernet1_2.name
          }
        }
      }
      destination {
        static_translation {
          address = "10.3.3.4"
        }
      }
    }
  }
}

# Security Rule

resource "panos_security_rule_group" "allow_app_traffic" {
  position_keyword = "top"
  depends_on = [panos_service_object.service-9090,
                panos_address_group.cts-addr-grp-web,
                panos_zone.internet_zone,
                panos_zone.dmz_zone,
                panos_zone.app_zone]
  rule {
    name                  = "Allow traffic to BIG-IP"
    source_zones          = ["Internet"]
    source_addresses      = ["any"]
    source_users          = ["any"]
    hip_profiles          = ["any"]
    destination_zones     = ["DMZ"]
    destination_addresses = ["10.3.2.5"]
    applications          = ["any"]
    services              = ["service-http", "service-https", "service-9090"]
    categories            = ["any"]
    action                = "allow"
    description           = "Allow app traffic from Internet to BIG-IP"
  }
  rule {
    name                  = "Allow traffic from BIG-IP to App"
    source_zones          = ["DMZ"]
    source_addresses      = ["any"]
    source_users          = ["any"]
    hip_profiles          = ["any"]
    destination_zones     = ["Application"]
    destination_addresses = ["cts-addr-grp-web"]
    applications          = ["any"]
    services              = ["service-http", "service-https", "service-9090"]
    categories            = ["any"]
    action                = "allow"
    description           = "Allow app traffic from BIG-IP to app server"
  }
}
