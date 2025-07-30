# resource "unifi_network" "default" {
#   name    = "Default"
#   purpose = "corporate"
#   enabled = true
#   subnet  = "10.10.10.0/24"
#   vlan_id = 0
#
#   dhcp_enabled = true
#   dhcp_start   = "10.10.10.10"
#   dhcp_stop    = "10.10.10.250"
#
#   domain_name               = var.dns_domain
#   igmp_snooping             = true
#   internet_access_enabled   = true
#   multicast_dns             = true
#   network_group             = "LAN"
#   network_isolation_enabled = false
#
#   lifecycle {
#     ignore_changes = [
#       dhcp_v6_start,
#       dhcp_v6_stop,
#       ipv6_pd_start,
#       ipv6_pd_stop,
#       ipv6_ra_priority,
#       ipv6_ra_enable,
#       ipv6_ra_valid_lifetime,
#     ]
#   }
# }
#
# resource "unifi_network" "servers" {
#   name    = "Servers"
#   purpose = "corporate"
#   enabled = true
#   subnet  = "10.10.20.0/24"
#   vlan_id = 20
#
#   dhcp_dns = [
#     "10.10.20.10",
#     "10.10.20.1",
#   ]
#   dhcp_enabled = true
#   dhcp_start   = "10.10.20.10"
#   dhcp_stop    = "10.10.20.254"
#
#   domain_name               = var.dns_domain
#   igmp_snooping             = false
#   internet_access_enabled   = true
#   multicast_dns             = false
#   network_group             = "LAN"
#   network_isolation_enabled = false
#
#   lifecycle {
#     ignore_changes = [
#       dhcp_v6_start,
#       dhcp_v6_stop,
#       ipv6_pd_start,
#       ipv6_pd_stop,
#       ipv6_ra_priority,
#       ipv6_ra_enable,
#       ipv6_ra_valid_lifetime,
#     ]
#   }
# }
#
# resource "unifi_network" "internet" {
#   name    = "Internet only"
#   purpose = "corporate"
#   enabled = true
#   subnet  = "10.10.11.0/24"
#   vlan_id = 11
#
#   dhcp_enabled = true
#   dhcp_start   = "10.10.11.10"
#   dhcp_stop    = "10.10.11.254"
#
#   domain_name               = var.dns_domain
#   igmp_snooping             = true
#   internet_access_enabled   = true
#   multicast_dns             = true
#   network_group             = "LAN"
#   network_isolation_enabled = false
#
#   lifecycle {
#     ignore_changes = [
#       dhcp_v6_start,
#       dhcp_v6_stop,
#       ipv6_pd_start,
#       ipv6_pd_stop,
#       ipv6_ra_priority,
#       ipv6_ra_enable,
#       ipv6_ra_valid_lifetime,
#     ]
#   }
# }
#
# resource "unifi_network" "things" {
#   name    = "Things"
#   purpose = "corporate"
#   enabled = true
#   subnet  = "10.10.12.0/24"
#   vlan_id = 12
#
#   dhcp_enabled = true
#   dhcp_start   = "10.10.12.1"
#   dhcp_stop    = "10.10.12.254"
#
#   domain_name               = var.dns_domain
#   igmp_snooping             = true
#   internet_access_enabled   = true
#   multicast_dns             = true
#   network_group             = "LAN"
#   network_isolation_enabled = false
#
#   lifecycle {
#     ignore_changes = [
#       dhcp_v6_start,
#       dhcp_v6_stop,
#       ipv6_pd_start,
#       ipv6_pd_stop,
#       ipv6_ra_priority,
#       ipv6_ra_enable,
#       ipv6_ra_valid_lifetime,
#     ]
#   }
# }
#
# # resource "unifi_wlan" "lan" {
# #   name        = "LAN"
# #   passphrase  = var.wifi_lan_password
# #   security    = "wpapsk"
# #   wlan_band   = "both"
# #
# #   network_id  = 1
# # }
# #
# # resource "unifi_wlan" "internet" {
# #   name        = "Internet"
# #   passphrase  = var.wifi_internet_password
# #   security    = "wpapsk"
# #   wlan_band   = "2g"
# #
# #   network_id  = 11
# # }
# #
# # resource "unifi_wlan" "things" {
# #   name        = "Things"
# #   passphrase  = var.wifi_things_password
# #   security    = "wpapsk"
# #   wlan_band   = "2g"
# #
# #   network_id  = 11
# # }

data "cloudflare_ip_ranges" "cloudflare" {}

resource "unifi_port_forward" "cloudflare_https" {
  for_each = toset(data.cloudflare_ip_ranges.cloudflare.ipv4_cidrs)

  name                   = "CF HTTPS ${each.key}"
  dst_port               = 443
  fwd_ip                 = "10.10.20.10"
  fwd_port               = 443
  protocol               = "tcp"
  port_forward_interface = "wan"
  src_ip                 = each.key
}

resource "unifi_port_forward" "plex" {
  name                   = "Plex"
  dst_port               = 32400
  fwd_ip                 = "10.10.20.21"
  fwd_port               = 32400
  protocol               = "tcp_udp"
  port_forward_interface = "wan"
  src_ip                 = "any"
}
