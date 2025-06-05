

# Dynamic Address Group
resource "panos_address_group" "cts-addr-grp-web" {
    name = "cts-addr-grp-web"
    description = "web Servers"
    dynamic_match = "web"
#    dynamic_match = "'web' and 'app'"  # Example of multi-tag
}


# Dynamic Address Group
resource "panos_address_group" "cts-addr-grp-api" {
    name = "cts-addr-grp-api"
    description = "api Servers"
    dynamic_match = "api"
#    dynamic_match = "'web' and 'app'"  # Example of multi-tag
}

# Dynamic Address Group
resource "panos_address_group" "cts-addr-grp-db" {
    name = "cts-addr-grp-db"
    description = "db Servers"
    dynamic_match = "db"
#    dynamic_match = "'web' and 'app'"  # Example of multi-tag
}

# Dynamic Address Group
resource "panos_address_group" "cts-addr-grp-logging" {
    name = "cts-addr-grp-logging"
    description = "logging Servers"
    dynamic_match = "logging"
#    dynamic_match = "'web' and 'app'"  # Example of multi-tag
}