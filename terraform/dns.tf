

resource "unifi_dns_record" "romanpeters_dns" {
    name   = "*.romanpeters.nl"
    type   = "A"
    record = local.hosts_map["webserver"].ip
}

resource "unifi_user" "devices" {
  for_each = local.hosts_map

  mac              = each.value.mac
  name             = each.value.friendly_name
  note             = "Managed by Terraform"
  fixed_ip         = each.value.ip
  allow_existing   = true
  local_dns_record = "${each.key}.dev.romanpeters.nl"
}