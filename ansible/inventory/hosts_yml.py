#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "pyyaml",
# ]
# ///
"""
Dynamic Ansible inventory based on hosts.yml.
Hosts are grouped by OS: 'ubuntu', 'rhel', and 'nixos'.
Only hosts where os is 'ubuntu', 'rhel', or 'nixos' are included in the inventory.
"""
import yaml
import json
import os
import sys
import getpass


def load_hosts(yml_path):
    try:
        with open(yml_path, "r") as f:
            data = yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Error: hosts.yml not found at {yml_path}", file=sys.stderr)
        sys.exit(1)
    return data


def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", ".."))
    yml_file = os.path.join(project_root, "hosts.yml")
    hosts_data = load_hosts(yml_file)

    # Build inventory: ubuntu, rhel, and nixos groups
    inventory = {
        "ubuntu": {"hosts": []},
        "rhel": {"hosts": []},
        "nixos": {"hosts": []},
        "_meta": {"hostvars": {}},
    }
    for name, details in hosts_data.items():
        ip = details.get("ip")
        os_val = details.get("os", "").strip().lower()
        # Only include known Linux OS families
        if os_val not in ("ubuntu", "rhel", "nixos"):
            continue
        # Connect as the current user (root login is disabled)
        user = getpass.getuser()

        inventory[os_val]["hosts"].append(name)
        inventory["_meta"]["hostvars"][name] = {
            "ansible_host": ip,
            "ansible_user": user,
        }

    # Handle --list and --host flags
    if "--list" in sys.argv:
        print(json.dumps(inventory, indent=2))
        return
    if "--host" in sys.argv:
        host = sys.argv[sys.argv.index("--host") + 1]
        print(json.dumps(inventory["_meta"]["hostvars"].get(host, {}), indent=2))
        return

    # Default to list all
    print(json.dumps(inventory, indent=2))


if __name__ == "__main__":
    main()
