# 🏡 Personal Kubernetes Homelab

Welcome to the **Homelab** project! This repository contains the automated orchestration scripts and Kubernetes manifests to bootstrap and manage a local, production-grade Kubernetes homelab cluster on macOS using **OrbStack**, **Helm**, and **Bake**.

---

## 🚀 Architecture Overview

This homelab is engineered to be lightweight, secure, and reproducible:
- **Local Kubernetes Engine:** [OrbStack](https://orbstack.dev/) provides a fast, light, and low-overhead alternative to Docker Desktop / Minikube.
- **Task Orchestration:** [Bake](https://github.com/kyleburton/bake) acts as a modern, Bash-based replacement for `Make` to manage deployment tasks cleanly.
- **Ingress & TLS:** [Traefik Ingress Controller](https://traefik.io/) is deployed with automatic Let's Encrypt HTTPS certificates using the Cloudflare DNS-01 challenge, allowing for wildcard certificates (`*.noeg.ai`) and securing all local endpoints.

---

## 📁 Repository Structure

```text
├── .gemini/
│   └── preferences.md     # Codified AI agent behavior rules and design preferences
├── Bakefile               # Central orchestration task runner for the homelab
├── init.sh                # Bootstraps modern Bash (v4+) and Kyle Burton's Bake
├── argocd/
│   ├── values.yaml        # Helm chart configuration values for ArgoCD
│   ├── ingress-route.yaml # Traefik IngressRoute exposing argocd.noeg.ai
│   └── apps/              # ArgoCD Application manifests
│       └── grafana.yaml   # ArgoCD Application tracking charts/grafana
├── charts/                # Local Helm wrapper charts
│   └── grafana/           # Helm wrapper chart for Grafana
│       ├── Chart.yaml     # Wrapper chart dependency definition
│       └── values.yaml    # Grafana configuration Helm values
└── traefik/
    ├── values.yaml        # Helm chart configuration values for Traefik Ingress
    └── tls-store.yaml     # Custom TLSStore resource configuring wildcard SSL certs
```

* **[.gemini/preferences.md](file:///Users/mac/Documents/homelab/.gemini/preferences.md):** Stores codified design preferences and architectural constraints for Antigravity AI agents working in this repository (e.g., preference for Helm values over separate manifests).
* **[init.sh](file:///Users/mac/Documents/homelab/init.sh):** Detects or installs a modern `bash` (v4+), downloads/patches `bake` to utilize it, and checks environment health (e.g., Homebrew directories permissions, Xcode CLI tools).
* **[Bakefile](file:///Users/mac/Documents/homelab/Bakefile):** Contains automation routines for software installation, SSH key management, and Helm deployments.
* **[argocd/values.yaml](file:///Users/mac/Documents/homelab/argocd/values.yaml):** Configures ArgoCD server (insecure mode), Dex integration for GitHub OAuth, and access control policies.
* **[argocd/ingress-route.yaml](file:///Users/mac/Documents/homelab/argocd/ingress-route.yaml):** Exposes ArgoCD UI/API and CLI gRPC traffic securely via Traefik.
* **[argocd/apps/grafana.yaml](file:///Users/mac/Documents/homelab/argocd/apps/grafana.yaml):** Declares the ArgoCD Application resource that tracks the Git repository.
* **[charts/grafana/](file:///Users/mac/Documents/homelab/charts/grafana/):** Helm wrapper chart pulling the official Grafana community chart and overlaying local configurations.
* **[traefik/values.yaml](file:///Users/mac/Documents/homelab/traefik/values.yaml):** Configures HTTP-to-HTTPS redirection, Let's Encrypt integration via Cloudflare API token, persistent ACME storage, and exposes the dashboard at `traefik.noeg.ai`.
* **[traefik/tls-store.yaml](file:///Users/mac/Documents/homelab/traefik/tls-store.yaml):** Configures Traefik to serve a default wildcard certificate for `*.noeg.ai` and `noeg.ai`.

---

## 🛠️ Getting Started

Follow these steps to set up your local development machine and deploy the initial ingress stack.

### Step 1: Bootstrap the Task Runner

First, run the initialization script to download `bake` and ensure you have a modern Bash shell.

```bash
./init.sh
```

> [!NOTE]
> If `bake` is not in your `PATH` after installation, the script will prompt you with the line to add to your shell profile (e.g., `~/.zshrc`).

---

### Step 2: Install Local Dependencies

Automate the installation of all necessary system tools, including **OrbStack**, **kubectl (v1.33)**, **Helm**, and **GitHub CLI (gh)**.

```bash
bake install
```

---

### Step 3: Configure GitHub SSH Access (Optional)

Generate a secure Ed25519 SSH key and configure your macOS Keychain for git authentication:

```bash
bake setup-ssh
```

> [!TIP]
> This command prints the public key automatically. Copy it and add it to your [GitHub Settings](https://github.com/settings/keys).

---

### Step 4: Deploy Traefik Ingress

Before deploying the ingress, export your Cloudflare credentials so that Traefik can solve the DNS-01 ACME challenge:

```bash
export CF_DNS_API_TOKEN="your-cloudflare-dns-api-token"
export CF_ACME_EMAIL="your-email@example.com"
```

Once defined, run the deployment task:

```bash
bake deploy-traefik
```

This task will:
1. Initialize the Traefik Helm repository.
2. Create the `traefik` namespace.
3. Securely provision a Kubernetes secret containing your Cloudflare credentials.
4. Install/Upgrade Traefik using custom values.
5. Apply the default wildcard TLS Store (`*.noeg.ai`).

---

### Step 5: Deploy ArgoCD

To deploy ArgoCD, run the deployment task:

```bash
bake deploy-argocd
```

If credentials are not found in Kubernetes or in your environment, the task will automatically open the GitHub application registration page in your browser, output the exact values to use, and prompt you for the Client ID and Client Secret in the terminal.


This task will:
1. Initialize/update the ArgoCD Helm repository.
2. Create the `argocd` namespace.
3. Securely provision a Kubernetes secret containing your GitHub credentials.
4. Install/Upgrade ArgoCD.
5. Deploy the Traefik IngressRoute allowing access via `argocd.noeg.ai`.
6. Restart the ArgoCD server/dex pods to ensure configurations apply immediately.

---

### Step 6: Deploy Grafana

To deploy Grafana via ArgoCD, run the deployment task:

```bash
bake deploy-grafana
```

If Grafana OAuth credentials are not found, the task will automatically prompt you to register a new GitHub OAuth App and enter the Client ID and Client Secret.

> [!IMPORTANT]
> Since ArgoCD pulls configurations directly from GitHub, you must commit and push your local files (e.g. `charts/grafana/` and `argocd/apps/grafana.yaml`) to your repository on GitHub.
> 
> To test your changes on a feature branch (e.g. `feat/grafana-deploy`) before merging them into `main`, push to your branch and run:
> ```bash
> argocd app set grafana --revision feat/grafana-deploy
> ```
> Once verified and merged into `main`, reset the application to track `main`:
> ```bash
> argocd app set grafana --revision main
> ```

This task will:
1. Create the `monitoring` namespace.
2. Securely provision the GitHub OAuth secrets for Grafana.
3. Apply the `grafana.yaml` manifest, prompting ArgoCD to track the `main` branch of this Git repository and deploy the Helm wrapper chart located at `charts/grafana` automatically.

---

## 🔒 Configuration Details

### Ingress & SSL
* **HTTP redirection:** Traefik is configured to redirect all HTTP traffic on port `80` to HTTPS on port `443` automatically.
* **Persistent Certs:** ACME certificates are stored in `/data/acme.json` backed by a `1Gi` persistent volume claim (`acme-certs`) provisioned by OrbStack's default local-path storage class.
* **Dashboard Access:** The secure Traefik dashboard is accessible at `https://traefik.noeg.ai/dashboard/`.
* **ArgoCD Access:** ArgoCD is exposed at `https://argocd.noeg.ai` using Dex GitHub integration with admin rights mapped specifically to user `nagonzalez`. All other logins are restricted by default.
* **Grafana Access:** Grafana is exposed at `https://grafana.noeg.ai` using GitHub OAuth. User `nagonzalez` is granted server-wide `GrafanaAdmin` rights, while all other users are blocked from logging in.
