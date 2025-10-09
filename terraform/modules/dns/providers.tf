
terraform {
  required_version = ">= 1.0"
  required_providers {
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
