# Ansible Collection - nagonzalez.perforce

This collection provides Ansible roles to automate the installation, configuration, and management of Perforce Helix Core components—specifically the Perforce Server (`p4d`), Perforce Proxy (`p4p`), and Perforce Broker (`p4broker`) using `p4dctl`.

## Included Roles

* **[p4](roles/p4/README.md)**: Installs and configures Perforce Helix Core services managed under `p4dctl`.

## Requirements

* **Ansible**: `^2.15.0`
* **Target Operating Systems**: Ubuntu / Debian (tested and validated on Ubuntu 24.04 LTS)

## Installation

### Local Development / Manual Installation

To install the collection for local use or development:

```bash
# 1. Build the collection package
ansible-galaxy collection build

# 2. Install the built package locally
ansible-galaxy collection install nagonzalez-perforce-1.0.0.tar.gz
```

Alternatively, clone or link this repository path directly into your Ansible configuration's `collections_paths` directory under the path structure `ansible_collections/nagonzalez/perforce`.

## Usage Example

Reference the `p4` role inside your playbooks like this:

```yaml
---
- hosts: perforce_servers
  become: true
  tasks:
    - name: Configure Perforce service
      ansible.builtin.import_role:
        name: nagonzalez.perforce.p4
      vars:
        p4_server_name: "master"
        p4_port: "1666"
        p4_case: 1
```

## License

MIT
