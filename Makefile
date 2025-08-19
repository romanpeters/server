# Makefile for managing the project

# Default help
.DEFAULT_GOAL := help

# Variables
PYTHON_DEPS = $(shell cat requirements.txt)
PRE_COMMIT_CONFIG = .pre-commit-config.yaml
SHELL := /bin/bash

# Phony targets
.PHONY: help lint vars terraform/plan terraform/apply terraform/destroy ansible/webserver ansible/nixos docker/up docker/down test/ansible test/terraform clean

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  lint             Lint the project"
	@echo "  vars             Generate variable files"
	@echo "  terraform        Apply Terraform changes"
	@echo "  webserver        Run the webserver playbook"
	@echo "  nixos            Run the nixos_deploy playbook"
	@echo "  check            Run all tests"
	@echo "  status           Check the status of the project"


lint: vars ## Lint the project
	@echo "Linting the project..."
	@pre-commit run --all-files

vars: ## Generate variable files
	@echo "Generating variable files..."
	@scripts/write_vars.py
	@scripts/write_dotenvs.py

terraform: ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@. data/.envrc && \
	 cd terraform && \
	 terraform init && \
	 terraform apply -var-file=vars.tfvars
	@make status/dns
	@make status/hosts

ansible: ## Run Ansible playbooks
	@echo "Running Ansible playbooks..."
	@. data/.envrc && \
	 cd ansible && \
	 ansible-playbook -i inventory/hosts_csv.py playbooks/configure_hosts.yml
	@make status/http
	@make status/hosts

webserver: ## Run the webserver playbook
	@echo "Running the webserver playbook..."
	@. data/.envrc && \
	 cd ansible && \
	 ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml
	@make status/http

nixos: ## Run the nixos_deploy playbook
	@echo "Running the nixos_deploy playbook..."
	@. data/.envrc && \
	 cd ansible && \
	 ansible-playbook -i inventory/hosts_csv.py playbooks/nixos_deploy.yml

status/dns: ## Check the status of the DNS
	@echo "Checking the status of the DNS..."
	@tests/dns_resolution.py

status/http: ## Check the status of the project
	@echo "Checking the status of the project..."
	@tests/http_status.py

status/hosts: ## Check the status of the hosts
	@echo "Checking the status of the hosts..."
	@tests/hosts_status.py

status: status/dns status/http status/hosts ## Check the status of the project

check/ansible: ## Run ansible tests
	@echo "Running ansible tests..."
	@cd ansible && \
	 ansible-playbook -i inventory/hosts_csv.py playbooks/webserver.yml --syntax-check && \
	 ansible-playbook -i inventory/hosts_csv.py playbooks/nixos_deploy.yml --syntax-check

check/terraform: ## Run terraform tests
	@echo "Running terraform tests..."
	@cd terraform && \
	 terraform fmt --recursive

check:   check/ansible check/terraform ## Run all tests
