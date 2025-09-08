variable "unifi_url" {
  description = "The URL of the UniFi controller"
  type        = string
}

variable "unifi_username" {
  description = "The username for UniFi API"
  type        = string
  default     = ""
}

variable "unifi_api_key" {
  description = "The API key for UniFi authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "proxmox_url" {
  description = "The URL of the Proxmox server"
  type        = string
}

variable "proxmox_api_key" {
  description = "The API key for Proxmox authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_api_key" {
  description = "The API key for Cloudflare authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "cloudflare_zone_id" {
  description = "The ID for the Cloudflare Zone"
  type        = string
  default     = ""
}

variable "root_password" {
  description = "Password for the root user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_key" {
  description = "SSH public key for the root user"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Public domain name"
  type        = string
}

variable "dns_domain" {
  description = "Local DNS domain name"
  type        = string
}

variable "wifi_lan_password" {
  description = "Password for Wifi SSID LAN"
  type        = string
  sensitive   = true
  default     = ""
}

variable "wifi_internet_password" {
  description = "Password for Wifi SSID Internet"
  type        = string
  sensitive   = true
  default     = ""
}

variable "wifi_things_password" {
  description = "Password for Wifi SSID Things"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tailscale_oauth_client_id" {
  type      = string
  sensitive = true
}

variable "tailscale_oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "tailnet_name" {
  type    = string
  default = ""
}
