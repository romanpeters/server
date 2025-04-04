variable "unifi_url" {
  description = "The URL of the UniFi controller"
  type        = string
}

variable "unifi_username" {
  description = "The username for UniFi API"
  type        = string
}

variable "unifi_password" {
  description = "The password for UniFi API"
  type        = string
  sensitive   = true
}

variable "proxmox_url" {
  description = "The URL of the Proxmox server"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "The API token ID for Proxmox authentication"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "The API token secret for Proxmox authentication" 
  type        = string
  sensitive   = true
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