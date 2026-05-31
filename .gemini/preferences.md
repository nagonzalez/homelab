# Antigravity Developer Preferences

This directory contains codified rules and preferences for AI agents working in this repository.

## 🛠️ Infrastructure & Deployment Preferences

### 1. Centralize Configurations in Helm Values
- **Preference**: Always prioritize using a Helm chart's native `values.yaml` configuration to declare resources (Ingresses, Services, ConfigMaps, RBAC) instead of writing separate custom Kubernetes manifests (e.g., Traefik `IngressRoute` CRDs) whenever possible.
- **Service Annotations**: Inject controller-specific routing options (like setting `traefik.ingress.kubernetes.io/service.serversscheme: h2c` for Traefik gRPC backend multiplexing) directly into the Service annotations inside the Helm chart (`server.service.annotations`) rather than writing standalone routing objects.
- **Exception (Multi-Protocol gRPC Backends)**: When deploying services like ArgoCD that multiplex HTTP/1.1 (for standard Web UI) and HTTP/2 (for gRPC CLI) on the same port, standard Ingress objects and Service-level annotations do not support routing both protocols correctly (forcing `h2c` on the Service level breaks the HTTP/1.1 Web UI, resulting in a 502 Bad Gateway). For these specific multi-protocol workloads, use a separate Traefik `IngressRoute` CRD to explicitly split the traffic by headers/content-type.
