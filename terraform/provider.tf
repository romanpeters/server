terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
    unifi = {
      source = "filipowm/unifi"
      version = "1.0.0"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_api_token_id     = var.proxmox_api_id
  pm_api_token_secret = var.proxmox_api_key
  pm_tls_insecure = true
}

provider "unifi" {
  api_key        = var.unifi_api_key
  api_url        = var.unifi_url
  allow_insecure = true
}
