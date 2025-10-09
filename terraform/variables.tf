variable "unifi_url" {
  description = "The URL of the UniFi controller"
  type        = string
}

variable "unifi_username" {
  description = "The username for UniFi API"
  type        = string
}

variable "unifi_api_key" {
  description = "The API key for UniFi authentication"
  type        = string
  sensitive   = true
}

variable "proxmox_url" {
  description = "The URL of the Proxmox server"
  type        = string
}


variable "cloudflare_api_key" {
  description = "The API key for Cloudflare authentication"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "The ID for the Cloudflare Zone"
  type        = string
}

variable "root_password" {
  description = "Password for the root user"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "SSH public key for the root user"
  type        = string
}

variable "ssh_private_key_file" {
  description = "SSH private key path"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "full_name" {
  description = "Full name of the primary user"
  type        = string
}

variable "username" {
  description = "Username to create in the LXC container"
  type        = string
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

variable "ubuntu_lxc_template" {
  description = "The LXC template to use for the Ubuntu container"
  type        = string
}
