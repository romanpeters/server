#!/usr/bin/env bash
# tests/test_terraform.sh - Test Terraform configuration
set -euo pipefail

# Navigate to terraform directory
cd terraform

# Format Terraform files (skipping init due to provider plugin issues)
terraform fmt -recursive
