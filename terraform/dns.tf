data "http" "public_ip" {
  url = "https://api.ipify.org"
}

resource "unifi_dns_record" "dns_wildcard" {
  name   = "*.${var.domain_name}"
  type   = "A"
  record = local.hosts_map["webserver"].ip
}

resource "unifi_dns_record" "devices" {
  for_each = { for k, v in local.hosts_map : k => v }

  name   = each.value.name
  type   = "A"
  record = each.value.ip
}

resource "unifi_user" "devices" {
  # Exclude the controller itself (unifi) from DNS settings
  for_each = { for k, v in local.hosts_map : k => v if k != "unifi" }

  mac            = each.value.mac
  name           = each.value.friendly_name
  note           = "Managed by Terraform"
  fixed_ip       = each.value.ip
  allow_existing = true
  #local_dns_record = "${each.key}.${var.dns_domain}"
}

resource "cloudflare_dns_record" "domain_name" {
  zone_id = var.cloudflare_zone_id
  comment = "Managed by Terraform"
  content = chomp(data.http.public_ip.response_body)
  name    = var.domain_name
  proxied = true
  ttl     = 1
  type    = "A"
}

resource "cloudflare_dns_record" "www" {
  zone_id = var.cloudflare_zone_id
  comment = "Managed by Terraform"
  content = var.domain_name
  name    = "www.${var.domain_name}"
  proxied = true
  ttl     = 1
  type    = "CNAME"
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = { for k, v in local.services_map : k => v if v.public == "true" }

  zone_id = var.cloudflare_zone_id
  comment = "Managed by Terraform"
  content = chomp(data.http.public_ip.response_body)
  name    = "${each.value.name}.${var.domain_name}"
  proxied = true
  ttl     = 1
  type    = "A"

  lifecycle {
    ignore_changes = [content]
  }
}
