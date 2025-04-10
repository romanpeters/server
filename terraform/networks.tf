resource "unifi_network" "default" {
    name                         = "Default"
    purpose                      = "corporate"
    enabled                      = true
    subnet                       = "10.10.10.0/24"
    vlan_id                      = 0

    dhcp_enabled                 = true
    dhcp_start                   = "10.10.10.10"
    dhcp_stop                    = "10.10.10.250"

    domain_name                  = "internal"
    igmp_snooping                = true
    internet_access_enabled      = true
    multicast_dns                = true
    network_group                = "LAN"
    network_isolation_enabled    = false

    lifecycle {
      ignore_changes = [
        dhcp_v6_start,
        dhcp_v6_stop,
        ipv6_pd_start,
        ipv6_pd_stop,
        ipv6_ra_priority,
        ]
    }
}

resource "unifi_network" "servers" {
    name                       = "Servers"
    purpose                    = "corporate"
    enabled                    = true
    subnet                     = "10.10.20.0/24"
    vlan_id                    = 20

    dhcp_dns                   = [
        "10.10.20.10",
        "10.10.20.1",
    ]
    dhcp_enabled               = true
    dhcp_start                 = "10.10.20.10"
    dhcp_stop                  = "10.10.20.254"

    igmp_snooping              = false
    internet_access_enabled    = true
    multicast_dns              = false
    network_group              = "LAN"
    network_isolation_enabled  = false

    lifecycle {
      ignore_changes = [
        dhcp_v6_start,
        dhcp_v6_stop,
        ipv6_pd_start,
        ipv6_pd_stop,
        ipv6_ra_priority,
        ]
    }
}

resource "unifi_network" "internet" {
    name                       = "Internet only"
    purpose                    = "corporate"
    enabled                    = true
    subnet                     = "10.10.11.0/24"
    vlan_id                    = 11

    dhcp_enabled               = true
    dhcp_start                 = "10.10.11.10"
    dhcp_stop                  = "10.10.11.254"
    
    domain_name                = "guest"
    igmp_snooping              = true
    internet_access_enabled    = true
    multicast_dns              = true
    network_group              = "LAN"
    network_isolation_enabled  = false

    lifecycle {
      ignore_changes = [
        dhcp_v6_start,
        dhcp_v6_stop,
        ipv6_pd_start,
        ipv6_pd_stop,
        ipv6_ra_priority,
        ]
    }
}

resource "unifi_network" "things" {
    name                       = "Things"
    purpose                    = "corporate"
    enabled                    = true
    subnet                     = "10.10.12.0/24"
    vlan_id                    = 12

    dhcp_enabled               = true
    dhcp_start                 = "10.10.12.1"
    dhcp_stop                  = "10.10.12.254"
    
    domain_name                = "things"
    igmp_snooping              = true
    internet_access_enabled    = true
    multicast_dns              = true
    network_group              = "LAN"
    network_isolation_enabled  = false

    lifecycle {
      ignore_changes = [
        dhcp_v6_start,
        dhcp_v6_stop,
        ipv6_pd_start,
        ipv6_pd_stop,
        ipv6_ra_priority,
        ]
    }
}