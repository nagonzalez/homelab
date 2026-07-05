# Antigravity Developer Preferences

This directory contains codified rules and preferences for AI agents working in this repository.

## 🛠️ Infrastructure & Deployment Preferences

### 1. Centralize Configurations in Helm Values
- **Preference**: Always prioritize using a Helm chart's native `values.yaml` configuration to declare resources (Ingresses, Services, ConfigMaps, RBAC) instead of writing separate custom Kubernetes manifests (e.g., Traefik `IngressRoute` CRDs) whenever possible.
- **Service Annotations**: Inject controller-specific routing options (like setting `traefik.ingress.kubernetes.io/service.serversscheme: h2c` for Traefik gRPC backend multiplexing) directly into the Service annotations inside the Helm chart (`server.service.annotations`) rather than writing standalone routing objects.
- **Exception (Multi-Protocol gRPC Backends)**: When deploying services like ArgoCD that multiplex HTTP/1.1 (for standard Web UI) and HTTP/2 (for gRPC CLI) on the same port, standard Ingress objects and Service-level annotations do not support routing both protocols correctly (forcing `h2c` on the Service level breaks the HTTP/1.1 Web UI, resulting in a 502 Bad Gateway). For these specific multi-protocol workloads, use a separate Traefik `IngressRoute` CRD to explicitly split the traffic by headers/content-type.

### 2. Application Deployment Methods
- **ArgoCD-managed Applications**: Applications and charts managed by ArgoCD are structured with their Helm wrapper charts and configuration resources under the `argocd/` folder (with applications under `argocd/apps/`, and their wrapper charts under `charts/` like `charts/grafana` and `charts/prometheus`).
- **Helm-managed Applications**: Core routing infrastructure (such as Traefik) and ArgoCD itself are deployed and upgraded manually using Helm releases via the `Bakefile`.

### 3. Testing Changes via Feature Branches
- **Workflow**: Always create Git feature branches for testing new configurations.
- **ArgoCD Revision Override**: Use ArgoCD's CLI revision override to test changes on a feature branch without affecting `main`:
  ```bash
  argocd app set <app-name> --revision <branch-name>
  ```
  After verifying, reset the revision to `main` and merge:
  ```bash
  argocd app set <app-name> --revision main
  ```

### 4. Pull Request Review and Merging Workflow
- **Preference**: When working with git, always create pull requests for changes and wait for the USER to manually review and approve them. Never merge pull requests automatically.

## 💻 Development & Scripting Preferences

### 1. Bakefile Task Ordering
- **Preference**: Keep task declarations and their corresponding function definitions in the `Bakefile` ordered alphabetically to ensure they are easy for humans to review and locate.

### 2. Idempotent Scripts and Automation
- **Preference**: Ensure all scripts, tasks, and playbooks are written to be fully idempotent. They must verify if the target state is already met before performing modifications, exiting gracefully and reporting success if no action is required.

### 3. Python Code Formatting
- **Preference**: Always format Python script files (e.g., dynamic inventory scripts) using the `black` code formatter (running via the virtual environment: `.venv/bin/black`) after making modifications to ensure code style consistency.
