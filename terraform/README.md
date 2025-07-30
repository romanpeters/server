# DNS Configuration

This directory contains Terraform configurations for managing DNS records across different providers (UniFi and Cloudflare) for your infrastructure.

## Overview

The DNS configuration manages:
- Local DNS records in UniFi Controller
- Public DNS records in Cloudflare
- Dynamic public IP resolution
- Wildcard subdomain configuration

## Components

### 1. Public IP Resolution
- Uses `ipify.org` API to dynamically fetch the public IP address
- This IP is used for A records in Cloudflare

### 2. UniFi DNS Configuration
- Creates local DNS records for all devices in the infrastructure
- Maps device hostnames to their fixed IP addresses
- Supports wildcard subdomain configuration

### 3. Cloudflare DNS Configuration
- Manages public DNS records for your domain
- Creates A record for the root domain
- Creates CNAME record for www subdomain
- Creates A records for public services
- All records are proxied through Cloudflare for security

## Required Variables

The following variables must be set in your `vars.tfvars` file:

```hcl
unifi_url        = "https://your-unifi-controller"
unifi_username   = "your-unifi-username"
unifi_api_key    = "your-unifi-api-key"
cloudflare_api_key = "your-cloudflare-api-key"
cloudflare_zone_id = "your-cloudflare-zone-id"
domain_name      = "your-domain.com"
dns_domain       = "your-local-domain"
```

## Resource Details

### `unifi_dns_record.dns_wildcard`
- Creates a wildcard DNS record (`*.your-domain.com`)
- Points to the webserver's IP address

### `unifi_user.devices`
- Creates local DNS records for all devices
- Maps device hostnames to their fixed IP addresses
- Uses device MAC addresses for identification

### `cloudflare_dns_record.domain_name`
- Creates an A record for the root domain
- Points to the current public IP address
- Proxied through Cloudflare

### `cloudflare_dns_record.www`
- Creates a CNAME record for www subdomain
- Points to the root domain
- Proxied through Cloudflare

### `cloudflare_dns_record.dns_record`
- Creates A records for public services
- Only creates records for services marked as public
- Points to the current public IP address
- Proxied through Cloudflare

## Important Notes

1. The public IP resolution is dynamic and will update automatically
2. All Cloudflare records are set to TTL=1 and are proxied
3. The `ignore_changes` lifecycle rule is set for public IP content to prevent unnecessary updates
4. Local DNS records are managed through the UniFi controller
5. Make sure to keep your API keys and sensitive information secure

## Usage

1. Set up your variables in `vars.tfvars`
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Apply the configuration:
   ```bash
   terraform apply -var-file=vars.tfvars
   ```

## Maintenance

- Regularly check your public IP address to ensure it hasn't changed unexpectedly
- Review Cloudflare DNS records periodically
- Update API keys and credentials as needed
- Monitor UniFi controller for any local DNS issues
