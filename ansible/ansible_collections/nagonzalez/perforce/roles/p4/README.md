# Ansible Role: Perforce (`nagonzalez.perforce.p4`)

This Ansible role automates the installation and configuration of Perforce Helix Core services on Debian/Ubuntu systems. It configures the official Perforce repository, installs Perforce binaries, sets up the dedicated system service account, configures a server instance under `p4dctl`, and ensures the service is running.

## Features

- **Package Management**: Configures the official Perforce APT repository and keys, installing version-specific packages for `p4-server`, `p4-proxy`, and `p4-broker`.
- **System Administration**: Automatically sets up system users, groups, and home directories with appropriate permissions.
- **Instance Configuration**: Leverages Perforce's native `configure-p4d.sh` to initialize and register the default server instance.
- **Service Control**: Integrates server control under the native `p4dctl` command line manager.

## Requirements

- **Ansible Version**: `2.15` or newer.
- **Operating System**: Ubuntu / Debian (validated on Ubuntu 24.04).
- **Privileges**: Elevated privileges on target nodes (`become: true`).

## Role Variables

Below are the variables configured in [defaults/main.yml](defaults/main.yml) that customize the installation and service creation:

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `p4_package_version` | `2026.1-2972966` | Version of Perforce binaries to install from the APT repository. |
| `p4_packages` | `[p4-server, p4-proxy, p4-broker]` | List of packages to install pinned to `p4_package_version` and system distribution release. |
| `p4_user` | `perforce` | System username created to run Perforce services. |
| `p4_group` | `perforce` | System group created to run Perforce services. |
| `p4_password` | `GudL0ngAdminP@sswerd` | Superuser/Admin password for the default Perforce instance. |
| `p4_server_name` | `master` | Name of the Perforce server instance to configure. |
| `p4_port` | `"1666"` | Listen port for the Perforce server instance. |
| `p4_case` | `1` | Case sensitivity of the Perforce server (`0` for case-sensitive, `1` for case-insensitive). |
| `p4_root` | `/opt/perforce/servers/{{ p4_server_name }}` | Database root directory for the Perforce server instance. |

## Dependencies

None.

## Example Playbook

Below is an example playbook utilizing this role:

```yaml
---
- hosts: perforce_nodes
  become: true
  roles:
    - role: nagonzalez.perforce.p4
      vars:
        p4_server_name: "prod-helix"
        p4_port: "1666"
        p4_case: 1
        p4_password: "MySuperSecurePassword123"
```

## License

MIT
