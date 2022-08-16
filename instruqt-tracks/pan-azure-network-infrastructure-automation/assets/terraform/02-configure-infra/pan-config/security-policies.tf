

resource "panos_security_rule_group" "allow_app_traffic" {
  rule {
    name                  = "Allow public to talk to app"
    source_zones          = [panos_zone.public_zone.name]
    source_addresses      = ["any"]
    source_users          = ["any"]
    destination_zones     = [panos_zone.private_zone.name]
    destination_addresses = [data.terraform_remote_state.deploy-infra.outputs.privateipfwnic1]
    applications          = ["any"]
    services              = ["any"]
    categories            = ["any"]
    action                = "allow"
  }
}

resource "panos_service_group" "serf" {
    name = "static serf"
    services = [
        panos_service_object.serf.name,
    ]
}

resource "panos_service_object" "serf" {
    name = "serf_service"
    protocol = "tcp"
    destination_port = "8301"
}


resource "panos_security_rule_group" "allow_vault_app_network" {
    position_keyword = "top"
    #position_reference = panos_security_rule_group.deny_all.rule.0.name
    rule {
        name = "Vault to App VNet"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["10.2.1.0/24"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "allow_consul_app_network" {
    position_keyword = "top"
    #position_reference = panos_security_rule_group.deny_all.rule.0.name
    rule {
        name = "Consul to App VNet"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["10.2.2.0/24"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["10.3.0.0/16"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "allow_app_sharedservice_consul" {
    position_keyword = "top"
    #position_reference = panos_security_rule_group.deny_all.rule.0.name
    rule {
        name = "App VNet to Shared Service Consul"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["10.3.0.0/16"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["10.2.2.0/24"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}


resource "panos_security_rule_group" "out_traffic" {
    position_keyword = "top"
    #position_reference = panos_security_rule_group.deny_all.rule.0.name
    rule {
        name = "Allow outoging traffic"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["any"]
        source_users = ["any"]
        destination_zones = [panos_zone.public_zone.name]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

# resource "panos_security_rule_group" "deny_all" {
#     position_keyword = "bottom"
#     rule {
#         name = "Deny everything else"
#         source_zones = ["any"]
#         source_addresses = ["any"]
#         source_users = ["any"]
#         destination_zones = ["any"]
#         destination_addresses = ["any"]
#         applications = ["any"]
#         services = ["any"]
#         categories = ["any"]
#         action = "deny"
#     }
# }

# resource "panos_security_rule_group" "egressout" {
#   rule {
#     name                  = "egressout"
#     source_zones          = [panos_zone.private_zone.name]
#     source_addresses      = ["any"]
#     source_users          = ["any"]
#     destination_zones     = [panos_zone.public_zone.name]
#     destination_addresses = ["any"]
#     applications          = ["any"]
#     services              = ["any"]
#     categories            = ["any"]
#     action                = "allow"
#   }
# }

# resource "panos_service_object" "api" {
#     name = "api_service"
#     protocol = "tcp"
#     destination_port = "9094"
# }


# resource "panos_security_rule_group" "api-security" {
#   rule {
#     name                  = "api-security"
#     source_zones          = [panos_zone.private_zone.name]
#     source_addresses      = ["10.3.0.6"]
#     source_users          = ["any"]
#     destination_zones     = [panos_zone.private_zone.name]
#     destination_addresses = ["10.3.1.6"]
#     applications          = ["any"]
#     services              = [panos_service_object.api.name]
#     categories            = ["any"]
#     action                = "deny"
#   }
# }
# resource "panos_security_rule_group" "serf_traffic" {
#   rule {
#     name                  = "serf_traffic"
#     source_zones          = [panos_zone.private_zone.name]
#     source_addresses      = ["any"]
#     source_users          = ["any"]
#     destination_zones     = [panos_zone.private_zone.name]
#     destination_addresses = ["any"]
#     applications          = ["any"]
#     services              = [panos_service_group.serf.name]
#     categories            = ["any"]
#     action                = "allow"
#   }
# }
