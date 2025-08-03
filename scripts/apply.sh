#!/bin/bash

# Exit on error
set -e

# change dir to terraform
cd terraform

# Check if vars.tfvars exists
if [ ! -f "vars.tfvars" ]; then
    echo "Error: vars.tfvars file not found"
    exit 1
fi

# Load environment variables from .envrc
source ../data/.envrc

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Apply Terraform
echo "Applying Terraform configuration..."
terraform apply  -var-file=vars.tfvars

# Clean up environment variables
unset TF_VAR_proxmox_password
unset TF_VAR_root_password
unset TF_VAR_unifi_password
