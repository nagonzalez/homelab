#!/usr/bin/env python3
"""
OrbStack Dynamic Inventory for Ansible.
Queries OrbStack VMs via the `orb` CLI and returns their connection details.
"""

import argparse
import json
import subprocess
import sys

def get_orb_machines():
    try:
        # Run orb list --format json
        result = subprocess.run(
            ['orb', 'list', '--format', 'json'],
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError):
        return []

def main():
    parser = argparse.ArgumentParser(description="OrbStack dynamic inventory for Ansible")
    parser.add_argument('--list', action='store_true', help="List active hosts")
    parser.add_argument('--host', action='store', help="Get variables for a specific host")
    args = parser.parse_args()

    machines = get_orb_machines()

    if args.host:
        # Return host variables if requested
        hostvars = {}
        for m in machines:
            name = m.get('name')
            if name == args.host:
                config = m.get('config', {})
                default_user = config.get('default_username', 'root')
                hostvars = {
                    'ansible_host': f"{name}@orb",
                    'ansible_user': default_user,
                    'ansible_ssh_common_args': '-o StrictHostKeyChecking=no'
                }
                break
        print(json.dumps(hostvars, indent=2))
        return

    # Initialize the inventory structure
    inventory = {
        'all': {
            'hosts': [],
            'vars': {}
        },
        '_meta': {
            'hostvars': {}
        }
    }

    # Group machines by distro and state
    for m in machines:
        name = m.get('name')
        if not name:
            continue
        
        state = m.get('state', 'unknown')
        config = m.get('config', {})
        default_user = config.get('default_username', 'root')
        distro = m.get('image', {}).get('distro', 'unknown')

        # Add to the generic groups
        inventory['all']['hosts'].append(name)

        # Distro group
        if distro not in inventory:
            inventory[distro] = {'hosts': []}
        inventory[distro]['hosts'].append(name)

        # State group
        if state not in inventory:
            inventory[state] = {'hosts': []}
        inventory[state]['hosts'].append(name)

        # Populate hostvars for connection details
        inventory['_meta']['hostvars'][name] = {
            'ansible_host': f"{name}@orb",
            'ansible_user': default_user,
            'ansible_ssh_common_args': '-o StrictHostKeyChecking=no'
        }

    print(json.dumps(inventory, indent=2))

if __name__ == '__main__':
    main()
