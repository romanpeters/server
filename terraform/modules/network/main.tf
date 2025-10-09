
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
