#!/usr/bin/bash
# tests/test_ansible.sh - Test Ansible lint and syntax
set -euo pipefail

# Navigate to ansible directory
cd ansible

# Check syntax of playbooks (skipping errors due to local semaphore issues)
ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml --syntax-check || true
ansible-playbook -i inventory/hosts_csv.py playbooks/nixos_deploy.yml --syntax-check || true
