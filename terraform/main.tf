
module "proxmox" {
  source = "./modules/proxmox"

  root_password       = var.root_password
  ssh_key             = var.ssh_key
  ubuntu_lxc_template = var.ubuntu_lxc_template
  hosts               = local.hosts
}

module "dns" {
  source = "./modules/dns"

  domain_name        = var.domain_name
  cloudflare_zone_id = var.cloudflare_zone_id
  hosts              = local.hosts
  services           = local.services
}

module "network" {
  source = "./modules/network"
}
