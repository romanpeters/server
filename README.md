# Project Development Guide

This repository contains Terraform configurations, Ansible playbooks, and Molecule tests for managing infrastructure.

## Prerequisites

- Git
- Python 3.8+ and pip (or pip3)
- Docker Engine (for Molecule testing)
- (Optional) Nix & nix-shell (for local development isolation)

## Setup Development Environment

1. Install Python dependencies:
   ```bash
   pip install --user -r requirements.txt
   ```
3. Install pre-commit hooks:
   ```bash
   pre-commit install
   ```

## Linting and Formatting

Run all configured linters and formatters via pre-commit:
```bash
pre-commit run --all-files
```

## Inventory

Ansible uses a dynamic inventory script based on `hosts.csv`:
```bash
ansible-inventory -i ansible/inventory/hosts_csv.py --list
```

## Running Molecule Tests

To test the `webserver` role with Molecule (requires Docker):
```bash
cd tests/molecule/webserver
molecule test
```

## Applying Terraform

Terraform is used to provision infrastructure (DNS records, virtual machines/containers). To apply:
```bash
cd terraform
terraform init
terraform apply -auto-approve -var-file=vars.tfvars
```

## Ansible Playbooks

- **Webserver** (NGINX reverse proxy):
  ```bash
  ansible-playbook \
    -i ansible/inventory/hosts_csv.py \
    ansible/playbooks/webserver.yml
  ```

- **NixOS Deployment** (build & deploy NixOS configs):
  ```bash
  ansible-playbook \
    -i ansible/inventory/hosts_csv.py \
    ansible/playbooks/nixos_deploy.yml
  ```

## Continuous Integration

The `Jenkinsfile` defines stages to run Terraform, deploy NixOS hosts, and configure the webserver.

---
