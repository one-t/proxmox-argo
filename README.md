# ProxMox ArgoCD GitOps Repository

GitOps repository for managing Kubernetes applications deployed via ArgoCD on a K3s cluster.

## Repository Structure

```
proxmox-argo/
├── bootstrap/              # Projects and namespace definitions
│   ├── README.md          # Bootstrap pattern documentation
│   ├── demo-apps.yaml     # Demo apps project + namespace
│   └── staging.yaml       # Staging project + namespace
├── apps/                   # Application manifests
│   ├── README.md          # App deployment documentation  
│   ├── demo-apps/         # Demo namespace apps
│   │   ├── hello-world/
│   │   ├── cowsay-fortune/
│   │   ├── nicolas-cage/
│   │   ├── screaming-into-void/
│   │   └── cringe-meter/
│   └── staging/           # Staging namespace apps
│       └── hello-world/
└── README.md              # This file
```

## How It Works

### 1. Bootstrap Application
Created by cloud-init, monitors `bootstrap/` directory and creates:
- **AppProjects** - Define allowed source repos and destinations per namespace
- **Namespace Applications** - Deploy the isolated-namespace Helm chart

### 2. Apps ApplicationSet
Automatically discovers apps in `apps/*/*/` and creates Applications:
- Namespace derived from parent directory (`apps/NAMESPACE/APP-NAME`)
- Project set to namespace name for isolation
- Auto-sync enabled for GitOps workflow

### 3. Namespace Isolation
Each namespace gets:
- **Resource Quotas** - CPU, memory, pod limits
- **Network Policies** - Default deny + selective allow (DNS, ingress, external)
- **ServiceAccounts** - Admin (full access) and Viewer (read-only, no secrets)
- **AppProject** - Restricts deployments to specific namespace

## Adding a New Namespace

See `bootstrap/README.md` for detailed instructions.

Quick summary:
1. Create `bootstrap/my-namespace.yaml` with AppProject and namespace Application
2. Configure resource quotas and network policies
3. Commit and push - ArgoCD applies automatically

## Adding a New App

See `apps/README.md` for detailed instructions.

Quick summary:
1. Ensure namespace exists in `bootstrap/`
2. Create `apps/my-namespace/my-app/` directory
3. Add Kubernetes manifests (NO namespace field needed!)
4. Commit and push - ArgoCD deploys automatically

## Key Conventions

✅ **Namespace = Project name** - Each namespace has its own ArgoCD project

✅ **No hardcoded namespaces** - Derived from directory structure

✅ **Bootstrap first** - Projects and namespaces in `bootstrap/`, apps in `apps/`

✅ **GitOps workflow** - All changes via git commits, ArgoCD auto-syncs

## Current Namespaces

### demo-apps
- **Purpose:** Demo/testing environment
- **Quotas:** 2 CPU, 4Gi RAM, 30 pods
- **Apps:** hello-world, cowsay-fortune, nicolas-cage, screaming-into-void, cringe-meter

### staging
- **Purpose:** Staging environment
- **Quotas:** 1 CPU, 2Gi RAM, 20 pods
- **Apps:** hello-world

## Related Repositories

- **proxmox-k3s-cluster** - Terraform infrastructure and cloud-init
- **proxmox-argo-helm** - Helm charts (isolated-namespace)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ ProxMox K3s Cluster                                         │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ ArgoCD Namespace                                       │ │
│  │                                                        │ │
│  │  Bootstrap App ───► bootstrap/ ───► Projects +        │ │
│  │                                      Namespace Apps    │ │
│  │                                                        │ │
│  │  Apps ApplicationSet ───► apps/*/* ───► App deploys   │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌──────────────────────────┐  ┌──────────────────────────┐│
│  │ demo-apps Namespace      │  │ staging Namespace        ││
│  │  - Resource Quotas       │  │  - Resource Quotas       ││
│  │  - Network Policies      │  │  - Network Policies      ││
│  │  - ServiceAccounts       │  │  - ServiceAccounts       ││
│  │  - 5 apps running        │  │  - 1 app running         ││
│  └──────────────────────────┘  └──────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Access

- **ArgoCD UI:** `http://<gateway-ip>/argocd`
- **Apps:** `http://<gateway-ip>/<app-name>`
- **Staging Apps:** `http://<gateway-ip>/staging/<app-name>`

## Documentation

- `bootstrap/README.md` - Creating namespaces and projects
- `apps/README.md` - Deploying applications
- `proxmox-k3s-cluster/docs/DEPLOYMENT.md` - Infrastructure deployment
- `proxmox-k3s-cluster/docs/ARGOCD-ADMIN.md` - ArgoCD administration
