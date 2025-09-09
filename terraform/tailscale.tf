resource "tailscale_tailnet_key" "ansible" {
  ephemeral = true
  tags      = ["tag:servers", "tag:ansible"]
}

output "tailscale_authkey" {
  value     = tailscale_tailnet_key.ansible.key
  sensitive = true
}
