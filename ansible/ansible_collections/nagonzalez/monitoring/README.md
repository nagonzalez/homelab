# Ansible Collection - nagonzalez.monitoring

This collection provides Ansible roles to automate the configuration and deployment of monitoring components for the homelab.

## Included Roles

*   **[loki](roles/loki/README.md)**: Configures native Perforce log shipping (`p4 logexport`) to push structured CSV logs directly to Loki via OTLP.

## Requirements

*   **Ansible**: `^2.15.0`
*   **Target Operating Systems**: Ubuntu / Debian (tested and validated on Ubuntu 24.04 LTS)
*   **Helix Core (P4D)**: `^2024.2` (supporting `p4 logexport` OTLP logging)

## Usage Example

Refer to the `loki` role inside your playbooks like this:

```yaml
---
- name: Apply monitoring role
  hosts: perforce-commit
  become: true
  roles:
    - role: nagonzalez.monitoring.loki
      vars:
        loki_push_url: "https://loki.noeg.ai/otlp/v1/logs"
```

## License

MIT
