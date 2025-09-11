# Server Infrastructure Management

This repository contains the infrastructure as code for managing my personal server. It uses a combination of tools to provision and configure the system.

## Overview

- **Terraform:** For provisioning DNS records and other cloud resources.
- **Ansible:** For configuring the server, deploying applications, and managing services.
- **Docker:** For running containerized applications.
- **NixOS:** As the operating system for some hosts, with declarative configuration.
- **Packer:** For creating custom VM images.
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
- **Packer:** For building VM images.

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd server
   ```

2. **Install Python dependencies:**
   ```bash
   pip install --user -e .
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
  ansible-playbook -i inventory/hosts_yml.py playbooks/webserver.yml
  ```

## Packer

This project uses [Packer](https://www.packer.io/) to create a reusable Ubuntu VM image for Proxmox. The configuration is located in the `packer/ubuntu` directory.

To build the image, run the following command:

```bash
make packer
```

## Continuous Integration

The `Jenkinsfile` in the repository defines the CI/CD pipeline, which automates the following stages:

1. **Linting and Validation:** Runs `pre-commit` to check code quality.
2. **Terraform Apply:** Provisions infrastructure using Terraform.
3. **NixOS Deployment:** Deploys NixOS configurations to the target hosts.
4. **Webserver Configuration:** Configures the webserver using Ansible.

## Secrets Management

This project requires secrets such as API keys and passwords. These are managed via environment variables loaded from the `.envrc` file. You have two options for providing these secrets:

1.  **Directly in `.envrc` (Recommended for simplicity):**

    You can directly set the environment variables in the `.envrc` file. For example:

    ```bash
    export TF_VAR_cloudflare_api_key="your-api-key"
    ```

2.  **Using `gopass` (Optional):**

    If you use `gopass` for secret management, you can keep the existing setup. The `.envrc` file is pre-configured to use `gopass` to fetch secrets. For example, to set the Cloudflare API key, you would run:

    ```bash
    gopass insert cloudflare/tf_api_key
    ```

    This will prompt you to enter the API key, which will then be securely stored in `gopass` and made available to the project.

---
