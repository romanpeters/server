
variable "domain_name" {
  description = "Public domain name"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "The ID for the Cloudflare Zone"
  type        = string
}

variable "hosts" {
  description = "A map of hosts"
  type        = any
  default     = {}
}

variable "services" {
  description = "A map of services"
  type        = any
  default     = {}
}
