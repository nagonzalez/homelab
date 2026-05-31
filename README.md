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
├── Bakefile               # Central orchestration task runner for the homelab
├── init.sh                # Bootstraps modern Bash (v4+) and Kyle Burton's Bake
└── traefik/
    ├── values.yaml        # Helm chart configuration values for Traefik Ingress
    └── tls-store.yaml     # Custom TLSStore resource configuring wildcard SSL certs
```

* **[init.sh](file:///Users/mac/Documents/homelab/init.sh):** Detects or installs a modern `bash` (v4+), downloads/patches `bake` to utilize it, and checks environment health (e.g., Homebrew directories permissions, Xcode CLI tools).
* **[Bakefile](file:///Users/mac/Documents/homelab/Bakefile):** Contains automation routines for software installation, SSH key management, and Helm deployments.
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

## 🔒 Configuration Details

### Ingress & SSL
* **HTTP redirection:** Traefik is configured to redirect all HTTP traffic on port `80` to HTTPS on port `443` automatically.
* **Persistent Certs:** ACME certificates are stored in `/data/acme.json` backed by a `1Gi` persistent volume claim (`acme-certs`) provisioned by OrbStack's default local-path storage class.
* **Dashboard Access:** The secure Traefik dashboard is accessible at `https://traefik.noeg.ai/dashboard/`.
