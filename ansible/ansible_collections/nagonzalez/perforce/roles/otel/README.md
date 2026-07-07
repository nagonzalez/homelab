# nagonzalez.perforce.otel

Ansible role to configure native structured log shipping using OpenTelemetry Protocol (OTLP) to Loki or an OTel Collector for Perforce Helix Core.

## Requirements

- A running Perforce Helix Core server instance.
- OpenTelemetry Collector or Loki endpoint reachable by the target host.

## Role Variables

| Variable | Description | Default |
| --- | --- | --- |
| `otel_push_url` | Endpoint for the OTel Collector or Loki OTLP endpoint | `https://otel-collector.noeg.ai/v1/logs` |
| `otel_p4_port` | Helix Core Port | `1666` |
| `otel_p4_user` | Perforce superuser name | `perforce` |
| `otel_p4_password` | Perforce superuser password | `GudL0ngAdminP@sswerd` |
| `otel_p4_logs` | List of structured logs to ship | (See defaults/main.yml) |

## License

MIT-0
