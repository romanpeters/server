# Makefile for managing the project

# Default help
.DEFAULT_GOAL := help

# Variables
PRE_COMMIT_CONFIG = .pre-commit-config.yaml
SHELL := /bin/bash
LIMIT ?=
LIMIT_CMD = $(if $(LIMIT),--limit $(LIMIT),)

# Phony targets
.PHONY: help lint vars clean-dotenvs terraform ansible webserver nixos status check docker \
	check/ansible check/terraform status/dns status/http status/hosts inventory

help:
	@echo "Usage: make [target] [LIMIT=host]"
	@echo ""
	@echo "Targets:"
	@echo "  pre-commit       Lint the project"
	@echo "  vars             Generate variable files"
	@echo "  clean-dotenvs    Remove generated .env files"
	@echo "  terraform        Apply Terraform changes"
	@echo "  webserver        Run the webserver playbook"
	@echo "  nixos            Run the nixos_deploy playbook"
	@echo "  check            Run all tests"
	@echo "  status           Check the status of the project"
	@echo "  inventory        Show the ansible inventory"


pre-commit: vars ## Lint the project
	@echo "Linting the project..."
	# Run pre-commit twice to format and then lint
	@pre-commit run --all-files || pre-commit run --all-files

vars: vars-terraform vars-ansible vars-nixos vars-dotenvs ## Generate variable files

vars-terraform:
	@echo "Generating Terraform variables..."
	@. .envrc && scripts/write_vars.py --format terraform

vars-ansible:
	@echo "Generating Ansible variables..."
	@. .envrc && scripts/write_vars.py --format ansible

vars-nixos:
	@echo "Generating NixOS variables..."
	@. .envrc && scripts/write_vars.py --format nixos

vars-dotenvs:
	@echo "Generating .env files..."
	@. .envrc && scripts/write_dotenvs.py

clean-dotenvs: ## Remove generated .env files
	@echo "Cleaning up .env files..."
	@find docker -name ".env" -type f -delete


terraform: vars-terraform ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@. .envrc && \
	 cd terraform && \
	 terraform init && \
	 terraform apply -var-file=vars.tfvars
	@make status/dns
	@make status/hosts


ansible: vars-ansible vars-dotenvs ## Run Ansible playbooks
	@echo "Running Ansible playbooks..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_hosts.yml $(LIMIT_CMD)); \
	$(MAKE) status/http; \
	$(MAKE) status/hosts

webserver: vars-ansible ## Run the webserver playbook
	@echo "Running the webserver playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_webserver.yml $(LIMIT_CMD)); \
	$(MAKE) status/http

nixos: vars-nixos ## Run the nixos_deploy playbook
	@echo "Running the nixos_deploy playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/deploy_nixos.yml $(LIMIT_CMD))

docker: vars-ansible vars-dotenvs ## Run the docker playbook
	@echo "Running the docker playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_docker.yml $(LIMIT_CMD))




inventory: ## Show the ansible inventory
	@echo "Showing the ansible inventory..."
	@. .envrc && \
	 cd ansible && \
	 ansible-inventory --list $(LIMIT_CMD)

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
	 ansible-playbook playbooks/*.yml --syntax-check $(LIMIT_CMD)

check/terraform: ## Run terraform tests
	@echo "Running terraform tests..."
	@cd terraform && \
	 terraform fmt --recursive

check:   check/ansible check/terraform ## Run all tests
