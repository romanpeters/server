#!/usr/bin/env python3
"""
Dynamic Ansible inventory based on hosts.csv.
Hosts are grouped by OS: 'ubuntu', 'rhel', and 'nixos'.
Only hosts where os is 'ubuntu', 'rhel', or 'nixos' are included in the inventory.
"""
import csv
import json
import os
import sys

def load_hosts(csv_path):
    rows = []
    try:
        with open(csv_path, newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                rows.append(row)
    except FileNotFoundError:
        print(f"Error: hosts.csv not found at {csv_path}", file=sys.stderr)
        sys.exit(1)
    return rows

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, '..', '..'))
    csv_file = os.path.join(project_root, 'hosts.csv')
    rows = load_hosts(csv_file)

    # Build inventory: ubuntu, rhel, and nixos groups
    inventory = {
        'ubuntu': {'hosts': []},
        'rhel': {'hosts': []},
        'nixos': {'hosts': []},
        '_meta': {'hostvars': {}}
    }
    for row in rows:
        name = row.get('name')
        ip = row.get('ip')
        os_val = row.get('os', '').strip().lower()
        # Only include known Linux OS families
        if os_val not in ('ubuntu', 'rhel', 'nixos'):
            continue
        # Ansible will always connect as root
        user = 'root'

        inventory[os_val]['hosts'].append(name)
        inventory['_meta']['hostvars'][name] = {
            'ansible_host': ip,
            'ansible_user': user
        }

    # Handle --list and --host flags
    if '--list' in sys.argv:
        print(json.dumps(inventory, indent=2))
        return
    if '--host' in sys.argv:
        host = sys.argv[sys.argv.index('--host') + 1]
        print(json.dumps(inventory['_meta']['hostvars'].get(host, {}), indent=2))
        return

    # Default to list all
    print(json.dumps(inventory, indent=2))

if __name__ == '__main__':
    main()