# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0

### Features
- Added the `p4` role to support installation and management of Perforce services.
- Automated APT repository configuration and Perforce GPG key integration.
- Automated service user/group administration with clean privilege separations.
- Configured and registered the default Perforce instance using native `configure-p4d.sh` script under `p4dctl` control.
- Added Molecule default scenario with Docker driver for testing on Ubuntu 24.04.
