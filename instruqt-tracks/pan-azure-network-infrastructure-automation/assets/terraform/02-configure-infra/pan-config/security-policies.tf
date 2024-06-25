

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
        name = "Allow Access to Vault Server"
        source_zones = [panos_zone.private_zone.name]
        source_addresses =  ["cts-addr-grp-api","cts-addr-grp-web","cts-addr-grp-db"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = [data.terraform_remote_state.deploy-infra.outputs.vault_ip]
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
        name = "Allow Access to Consul Server"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["10.0.0.0/8"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = [data.terraform_remote_state.deploy-infra.outputs.consul_ip]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}


resource "panos_security_rule_group" "cts-addr-grp-logging" {
    position_keyword = "top"
    rule {
        name = "Allow traffic to the logging servers"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["cts-addr-grp-api","cts-addr-grp-web","cts-addr-grp-db"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["cts-addr-grp-logging"]
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
        destination_addresses = ["10.2.0.0/16"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "allow_sharedservice_app" {
    position_keyword = "top"
    #position_reference = panos_security_rule_group.deny_all.rule.0.name
    rule {
        name = "Shared Service to App VNet"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["10.2.0.0/16"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["10.3.0.0/16"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "alow_web_access_api" {
    position_keyword = "top"
    rule {
        name = "Allow Web Access to API"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["cts-addr-grp-web"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["cts-addr-grp-api"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "allow_cts_pan" {
    position_keyword = "top"
    rule {
        name = "Allow CTS to PAN"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["any"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
}

resource "panos_security_rule_group" "alow_api_access_db" {
    position_keyword = "top"
    rule {
        name = "Allow API Access to DB"
        source_zones = [panos_zone.private_zone.name]
        source_addresses = ["cts-addr-grp-api"]
        source_users = ["any"]
        destination_zones = [panos_zone.private_zone.name]
        destination_addresses = ["cts-addr-grp-db"]
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
        name = "Allow outgoing traffic"
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
