#!/usr/bin/env bash
# tests/test_ansible.sh - Test Ansible lint and syntax
set -euo pipefail

# Navigate to ansible directory
cd "$(dirname "$0")/../ansible"

# Lint all roles/playbooks
../venv/bin/ansible-lint .

# Check syntax of playbooks
../venv/bin/ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml --syntax-check
../venv/bin/ansible-playbook -i inventory/hosts_csv.py playbooks/nixos_deploy.yml --syntax-check
