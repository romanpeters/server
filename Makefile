# =================================================================================================
# Makefile for managing the project
# =================================================================================================

# -------------------------------------------------------------------------------------------------
# Default help
# -------------------------------------------------------------------------------------------------
.DEFAULT_GOAL := help

# -------------------------------------------------------------------------------------------------
# Variables
# -------------------------------------------------------------------------------------------------
PRE_COMMIT_CONFIG = .pre-commit-config.yaml
SHELL := /bin/bash

# Ansible specific variables
ROLE ?=
ROLE_CMD = $(if $(ROLE),-e "role_to_run=$(ROLE)",)
HOST_LIST := $(if $(ROLE),$(shell grep -l "  - $(ROLE)" ansible/inventory/host_vars/*.yml | awk -F'[/.]' '{print $$(NF-1)}' | paste -sd, -),)
LIMIT_FOR_ROLE = $(if $(HOST_LIST),--limit $(HOST_LIST),)
LIMIT ?=
LIMIT_CMD = $(if $(LIMIT),--limit $(LIMIT),$(LIMIT_FOR_ROLE))

# Terraform specific variables
MODULE ?=
TARGET_CMD = $(if $(MODULE),-target=module.$(MODULE),)
REMAKE ?=
REMAKE_CMD = $(if $(REMAKE),-replace="$(REMAKE)",)

# -------------------------------------------------------------------------------------------------
# Phony targets
# -------------------------------------------------------------------------------------------------
.PHONY: help \
	all pre-commit vars clean-dotenvs hosts upload-data gopass-sync \
	terraform terraform/init terraform/plan terraform/apply \
	ansible webserver nixos packer server25 docker lxc-template-ubuntu \
	status status/dns status/http status/hosts \
	check check/ansible check/terraform \
	inventory

# =================================================================================================
# Main targets
# =================================================================================================

help:
	@echo "Usage: make [target] [LIMIT=host] [ROLE=role] [MODULE=module]"
	@echo ""
	@echo "Main targets:"
	@echo "  all                   Run all playbooks to build, provision and configure everything"
	@echo "  pre-commit            Lint the project"
	@echo "  vars                  Generate variable files"
	@echo "  clean-dotenvs         Remove generated .env files"
	@echo ""
	@echo "Tooling targets:"
	@echo "  terraform             Apply Terraform changes"
	@echo "  ansible               Run Ansible playbooks"
	@echo "  webserver             Run the webserver playbook"
	@echo "  nixos                 Run the nixos_deploy playbook"
	@echo "  packer                Build packer templates"
	@echo "  server25              Deploy server25"
	@echo "  docker                Run the docker playbook"
	@echo "  lxc-template-ubuntu   Create an LXC Ubuntu template"
	@echo ""
	@echo "Status and check targets:"
	@echo "  status                Check the status of the project"
	@echo "  check                 Run all tests"
	@echo "  inventory             Show the ansible inventory"


all: ## Run all playbooks
	@echo "Running all playbooks..."; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/all.yml -e @vars/main.yml $(LIMIT_CMD))

pre-commit: vars ## Lint the project
	@echo "Linting the project..."
	# Run pre-commit twice to format and then lint
	@pre-commit run --all-files || pre-commit run --all-files


# =================================================================================================
# Variable generation
# =================================================================================================

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


# =================================================================================================
# Tooling targets
# =================================================================================================

# -------------------------------------------------------------------------------------------------
# Terraform
# -------------------------------------------------------------------------------------------------
terraform: hosts terraform/apply ## Apply Terraform changes

terraform/init: ## Initialize Terraform
	@echo "Initializing Terraform..."
	@. .envrc && \
	 cd terraform && \
	 terraform init

terraform/plan: terraform/init vars-terraform ## Plan Terraform changes
	@echo "Planning Terraform changes..."
	@. .envrc && \
	 cd terraform && \
	 terraform plan -var-file=vars.tfvars $(TARGET_CMD)

terraform/apply: terraform/init vars-terraform ## Apply Terraform changes
	@echo "Applying Terraform changes..."
	@. .envrc && \
	 cd terraform && \
	 terraform apply -var-file=vars.tfvars $(REMAKE_CMD) $(TARGET_CMD)
	@make status/dns
	@make status/hosts

# -------------------------------------------------------------------------------------------------
# Ansible
# -------------------------------------------------------------------------------------------------
ansible: vars-ansible vars-dotenvs ## Run Ansible playbooks
	@echo "Running Ansible playbooks..."; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_hosts.yml -e @vars/main.yml $(LIMIT_CMD) $(ROLE_CMD)) \
	&& $(MAKE) status/http && $(MAKE) status/hosts

webserver: vars-ansible ## Run the webserver playbook
	@echo "Running the webserver playbook..."; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/configure_webserver.yml -e @vars/main.yml $(LIMIT_CMD)); \
	$(MAKE) status/http

nixos: vars-nixos ## Run the nixos_deploy playbook
	@echo "Running the nixos_playbook..."; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/deploy_nixos.yml -e @vars/main.yml $(LIMIT_CMD))

lxc-template-ubuntu: vars-ansible ## Create an LXC Ubuntu template
	@echo "Creating an LXC Ubuntu template..."; \
	. .envrc && \
	(cd ansible && ansible-playbook playbooks/create_lxc_template_ubuntu.yml -e @vars/main.yml $(LIMIT_CMD))

docker: ## Run the docker playbook
	@$(MAKE) ansible ROLE=docker

inventory: ## Show the ansible inventory


hosts:
	@echo "Downloading data from S3..."
	@. .envrc && scripts/download_data.py

upload-data:
	@echo "Uploading data to S3..."
	@. .envrc && scripts/upload_data.py ## Show the ansible inventory
	@echo "Showing the ansible inventory..."
	@. .envrc && \
	 cd ansible && \
	ansible-inventory --list $(LIMIT_CMD)

# -------------------------------------------------------------------------------------------------
# Packer
# -------------------------------------------------------------------------------------------------
packer: vars-packer ## Build packer templates
	@echo "Building packer VM template..."; \
	. .envrc && \
	./scripts/delete_packer_vm.py && \
	(cd packer/ubuntu && packer init . && packer build -var-file=../vars.pkrvars.hcl .)

# -------------------------------------------------------------------------------------------------
# Deployments
# -------------------------------------------------------------------------------------------------
server25: packer ## Deploy server25
	@echo "Deploying server25..."
	@$(MAKE) terraform REMAKE="proxmox_virtual_environment_vm.server25"
	@$(MAKE) ansible LIMIT=server25


# =================================================================================================
# Status and checks
# =================================================================================================

status: status/dns status/http status/hosts ## Check the status of the project

status/dns: ## Check the status of the DNS
	@echo "Checking the status of the DNS..."
	@tests/dns_resolution.py

status/http: ## Check the status of the project
	@echo "Checking the status of the project..."
	@tests/http_status.py

status/hosts: ## Check the status of the hosts
	@echo "Checking the status of the hosts..."
	@tests/hosts_status.py

check: check/ansible check/terraform ## Run all tests

check/ansible: ## Run ansible tests
	@echo "Running ansible tests..."
	@cd ansible && \
	 ansible-playbook playbooks/*.yml --syntax-check $(LIMIT_CMD)

check/terraform: terraform/init ## Run terraform tests
	@echo "Running terraform tests..."
	@cd terraform && \
	 terraform fmt --recursive && \
	 terraform validate
