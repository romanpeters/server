data "http" "public_ip" {
  url = "https://api.ipify.org"
}

resource "unifi_dns_record" "dns_wildcard" {
  name   = "*.${var.domain_name}"
  type   = "A"
  record = local.hosts["webserver"].ip
}

resource "unifi_dns_record" "devices" {
  for_each = { for k, v in local.hosts : k => v }

  name   = each.key
  type   = "A"
  record = each.value.ip
}

resource "unifi_user" "devices" {
  # Exclude the controller itself (unifi) from DNS settings
  for_each = { for k, v in local.hosts : k => v if k != "unifi" }

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
  for_each = { for k, v in local.services : k => v if lookup(v, "public", false) == true }

  zone_id = var.cloudflare_zone_id
  comment = "Managed by Terraform"
  content = var.domain_name
  name    = "${each.key}.${var.domain_name}"
  proxied = true
  ttl     = 1
  type    = "CNAME"

  lifecycle {
    ignore_changes = [content]
  }
}
