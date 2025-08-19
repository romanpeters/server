# Server Infrastructure Management

This repository contains the infrastructure as code for managing my personal server. It uses a combination of tools to provision and configure the system.

## Overview

- **Terraform:** For provisioning DNS records and other cloud resources.
- **Ansible:** For configuring the server, deploying applications, and managing services.
- **Docker:** For running containerized applications.
- **NixOS:** As the operating system for some hosts, with declarative configuration.
- **pre-commit:** For code linting and formatting to maintain code quality.
- **Jenkins:** For continuous integration and automated deployments.

## Getting Started

### Prerequisites

- **make:** To simplify project workflows.
- **Git:** For version control.
- **Python & pip:** For running scripts and tools.
- **Docker:** For running containerized applications and testing.
- **Ansible:** For configuration management.
- **Terraform:** For infrastructure provisioning.
- **(Optional) Nix & nix-shell:** For isolated development environments.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd server
   ```

2. **Install Python dependencies:**
   ```bash
   pip install --user -r requirements.txt
   ```

3. **Set up pre-commit hooks:**
   ```bash
   pre-commit install
   ```

## Usage

This project uses a `Makefile` to simplify common tasks. Below are the main commands:

- **`make help`**: Display all available `make` commands and their descriptions.
- **`make lint`**: Lint and format the codebase using `pre-commit`.
- **`make vars`**: Generate variable files required for Terraform and Ansible.
- **`make terraform`**: Apply Terraform changes to provision infrastructure.
- **`make webserver`**: Run the Ansible playbook to configure the webserver.
- **`make nixos`**: Deploy NixOS configurations using Ansible.
- **`make check`**: Run syntax checks and formatting checks for Ansible and Terraform.
- **`make status`**: Check the status of DNS, HTTP, and hosts.

### Manual Steps

If you prefer to run the tools manually, here are the equivalent commands:

- **Linting:**
  ```bash
  pre-commit run --all-files
  ```

- **Terraform:**
  ```bash
  cd terraform
  terraform init
  terraform apply -var-file=vars.tfvars
  ```

- **Ansible:**
  ```bash
  cd ansible
  ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml
  ```

## Continuous Integration

The `Jenkinsfile` in the repository defines the CI/CD pipeline, which automates the following stages:

1. **Linting and Validation:** Runs `pre-commit` to check code quality.
2. **Terraform Apply:** Provisions infrastructure using Terraform.
3. **NixOS Deployment:** Deploys NixOS configurations to the target hosts.
4. **Webserver Configuration:** Configures the webserver using Ansible.

---
