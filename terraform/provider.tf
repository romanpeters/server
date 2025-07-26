terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75.0"
    }
    unifi = {
      source  = "filipowm/unifi"
      version = "1.0.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_url
  api_token = var.proxmox_api_key
  insecure  = true
}

provider "unifi" {
  api_key        = var.unifi_api_key
  api_url        = var.unifi_url
  allow_insecure = true
}

provider "cloudflare" {
  api_token = var.cloudflare_api_key
}
