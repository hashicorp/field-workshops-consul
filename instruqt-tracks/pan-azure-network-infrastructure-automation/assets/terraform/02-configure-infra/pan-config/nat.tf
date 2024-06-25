
resource "panos_nat_rule_group" "app" {
  rule {
    name = "web_app"
    original_packet {
      source_zones          = ["public"]
      destination_zone      = "public"
      source_addresses      = ["any"]
      destination_addresses = [data.terraform_remote_state.deploy-infra.outputs.privateipfwnic1]
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
          address = data.terraform_remote_state.deploy-infra.outputs.web-lb
        }
      }
    }
  }
}


# outgoing nat rule
resource "panos_nat_rule_group" "egress-nat" {
  rule {
    name          = "Allow outbound traffic"
    audit_comment = "Ticket 12345"
    original_packet {
      source_zones          = [panos_zone.private_zone.name]
      destination_zone      = panos_zone.public_zone.name
      destination_interface = panos_ethernet_interface.ethernet1_1.name
      source_addresses      = ["any"]
      destination_addresses = ["any"]
    }
    translated_packet {
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = panos_ethernet_interface.ethernet1_1.name
          }
        }
      }
      destination {}
    }
  }
}


# between zones nat rule
resource "panos_nat_rule_group" "internal-nat" {
  rule {
    name          = "Allow internal traffic"
    audit_comment = "Ticket 12345"
    original_packet {
      source_zones          = [panos_zone.private_zone.name]
      destination_zone      = panos_zone.private_zone.name
      destination_interface = panos_ethernet_interface.ethernet1_2.name
      source_addresses      = ["any"]
      destination_addresses = ["any"]
    }
    translated_packet {
      source {
        dynamic_ip_and_port {
          interface_address {
            interface = panos_ethernet_interface.ethernet1_2.name
          }
        }
      }
      destination {}
    }
  }
}

# # outgoing nat rule
# resource "panos_nat_rule_group" "private-private" {
#   rule {
#     name          = "Allow private-private traffic"
#     audit_comment = "Ticket 12345"
#     original_packet {
#       source_zones          = [panos_zone.private_zone.name]
#       destination_zone      = panos_zone.private_zone.name
#       destination_interface = panos_ethernet_interface.ethernet1_2.name
#       source_addresses      = ["any"]
#       destination_addresses = ["any"]
#     }
#     translated_packet {
#       source {
#         dynamic_ip_and_port {
#           interface_address {
#             interface = panos_ethernet_interface.ethernet1_2.name
#           }
#         }
#       }
#       destination {}
#     }
#   }
# }


# # outgoing nat rule
# resource "panos_nat_rule_group" "egress-insidenat" {
#   rule {
#     name          = "Allow outbound inside traffic"
#     audit_comment = "Ticket 12345"
#     original_packet {
#       source_zones          = [panos_zone.private_zone.name]
#       destination_zone      = panos_zone.private_zone.name
#       destination_interface = panos_ethernet_interface.ethernet1_2.name
#       source_addresses      = ["any"]
#       destination_addresses = ["any"]
#     }
#     translated_packet {
#       source {
#         dynamic_ip_and_port {
#           interface_address {
#             interface = panos_ethernet_interface.ethernet1_2.name
#           }
#         }
#       }
#       destination {}
#     }
#   }
# }