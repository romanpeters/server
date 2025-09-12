terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.83.1"
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
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0"
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

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
}
