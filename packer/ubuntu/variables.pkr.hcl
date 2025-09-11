variable "proxmox_api_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_storage_pool" {
  type    = string
}

variable "proxmox_iso_storage_pool" {
  type    = string
}

variable "proxmox_bridge" {
  type    = string
}

variable "username" {
  type    = string
}

variable "email" {
  type    = string
}

variable "ssh_password_hashed" {
  type    = string
  default = env("PKR_VAR_ssh_password_hashed")
}

variable "ssh_key" {
  type    = string
}
