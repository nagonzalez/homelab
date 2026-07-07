# Changelog

All notable changes to this project will be documented in this file.

## 1.0.0

### Features
- Added the `loki` role to configure native Perforce log shipping (`p4 logexport`) directly to Grafana Loki via OTLP.
- Configured dynamic startup tasks for Perforce to ship commands, errors, events, integrity, and auth logs.
