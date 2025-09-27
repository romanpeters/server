
variable "root_password" {
  description = "Password for the root user"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "SSH public key for the root user"
  type        = string
}

variable "ubuntu_lxc_template" {
  description = "The LXC template to use for the Ubuntu container"
  type        = string
}

variable "hosts" {
  description = "A map of hosts"
  type        = any
  default     = {}
}
