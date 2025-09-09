## Project

This project combines Terraform, Ansible and nixOS to manage VM's and LXC's on Proxmox VE.

## Tools

You can check the Makefile for actual commands, but the basic usage is:

`make lint`         - run linters (pre-commit)
`make check`        - run syntax checks
`make terraform`    - run terraform apply
`make ansible`      - run ansible for all hosts (slow)
`make webserver`    - deploy webserver using ansible
`make nixos`        - deploy NixOS using ansible
`make status/dns`   - check status of DNS records
`make status/hosts` - check status of hosts
`make status/http`  - check status of HTTP services

Use these tools to verify any changes you have made.
You are also free to use other commandline tools, such as curl, dig, nslookup, ssh, etc.


## Files
Data sources are stored in the `data/` directory.
The data can be written to vars for Terraform, Ansible and Nixos using `make vars` (scripts/write_vars.py), this is only needed if the data has changed.
You can add your own tests in the `tests/` directory.
You should update the `README.md` file if you add new features or change existing ones.

## Python

The installed Python version is 3.13.

Python scripts should begin like this:
```
#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
# ]
# ///
```
This allows you to run the script by just its name, e.g. `./script.py`,
and it will automatically install the dependencies listed in the `dependencies` section.

## Ansible
Use Fully Qualified Module Names (FQMN) for Ansible tasks.

## Restrictions
You are not allowed to edit or remove these files:
- hosts.yml
- services.yml
- terraform/terraform.tfstate
Assume their content is correct. If a change is really needed, please ask.

You are allowed to run any (safe) command that you want.
