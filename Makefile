# Makefile for managing the project

# Default help
.DEFAULT_GOAL := help

# Variables
PRE_COMMIT_CONFIG = .pre-commit-config.yaml
SHELL := /bin/bash

ROLE ?=
ROLE_CMD = $(if $(ROLE),-e "role_to_run=$(ROLE)",)
HOST_LIST := $(if $(ROLE),$(shell grep -l "  - $(ROLE)" ansible/inventory/host_vars/*.yml | awk -F'[/.]' '{print $(NF-1)}' | paste -sd, -),)
LIMIT_FOR_ROLE = $(if $(HOST_LIST),--limit $(HOST_LIST),)

LIMIT ?=
LIMIT_CMD = $(if $(LIMIT),--limit $(LIMIT),$(LIMIT_FOR_ROLE))

# Phony targets
.PHONY: help all lint vars clean-dotenvs terraform ansible webserver nixos packer status check docker \
	check/ansible check/terraform status/dns status/http status/hosts inventory

help:
	@echo "Usage: make [target] [LIMIT=host] [ROLE=role]"
	@echo ""
	@echo "Targets:"
	@echo "  all              Run packer and terraform"
	@echo "  pre-commit       Lint the project"
	@echo "  vars             Generate variable files"
	@echo "  clean-dotenvs    Remove generated .env files"
	@echo "  terraform        Apply Terraform changes"
	@echo "  webserver        Run the webserver playbook"
	@echo "  nixos            Run the nixos_deploy playbook"
	@echo "  packer           Build packer templates"
	@echo "  check            Run all tests"
	@echo "  status           Check the status of the project"
	@echo "  inventory        Show the ansible inventory"

all: packer terraform ## Run packer and terraform



pre-commit: vars ## Lint the project
	@echo "Linting the project..."
	# Run pre-commit twice to format and then lint
	@pre-commit run --all-files || pre-commit run --all-files

vars: vars-terraform vars-ansible vars-nixos vars-dotenvs vars-packer ## Generate variable files

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

vars-packer:
	@echo "Generating Packer variables..."
	@. .envrc && scripts/write_vars.py --format packer

clean-dotenvs: ## Remove generated .env files
	@echo "Cleaning up .env files..."
	@find docker -name ".env" -type f -delete




terraform: terraform/apply ## Apply Terraform changes

terraform/plan: vars-terraform ## Plan Terraform changes
	@echo "Planning Terraform changes..."
	@. .envrc && \
	 cd terraform && \
	 terraform init && \
	 terraform plan -var-file=vars.tfvars

terraform/apply: vars-terraform ## Apply Terraform changes
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
	(cd ansible && ansible-playbook playbooks/configure_hosts.yml -e @vars/main.yml $(LIMIT_CMD) $(ROLE_CMD)) \
	&& $(MAKE) status/http && $(MAKE) status/hosts

webserver: vars-ansible ## Run the webserver playbook
	@echo "Running the webserver playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_webserver.yml -e @vars/main.yml $(LIMIT_CMD)); \
	$(MAKE) status/http

nixos: vars-nixos ## Run the nixos_deploy playbook
	@echo "Running the nixos_playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/deploy_nixos.yml -e @vars/main.yml $(LIMIT_CMD))

packer: vars-packer ## Build packer templates
	@echo "Building packer VM template..."; \
	. .envrc && \
	./scripts/delete_packer_vm.py && \
	(cd packer/ubuntu && packer init . && packer build -var-file=../vars.pkrvars.hcl .)




docker: vars-ansible vars-dotenvs ## Run the docker playbook


	@echo "Running the docker playbook..."; \
	trap '$(MAKE) clean-dotenvs' EXIT; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_docker.yml -e @vars/main.yml $(LIMIT_CMD))

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
