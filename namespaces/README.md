# Namespace Management

Namespaces are created using `namespace.yaml` files placed in app namespace directories.

## How It Works

The ArgoCD ApplicationSet watches for `apps/*/namespace.yaml` files and creates a namespace Application for each one found.

## Directory Structure

```
apps/
├── demo-apps/
│   ├── namespace.yaml          ← Creates demo-apps namespace
│   ├── hello-world/
│   │   └── deployment.yaml
│   └── cowsay-fortune/
│       └── deployment.yaml
├── production/
│   ├── namespace.yaml          ← Creates production namespace
│   └── api/
│       └── deployment.yaml
└── staging/
    ├── namespace.yaml          ← Creates staging namespace
    └── frontend/
        └── deployment.yaml
```

## Creating a New Namespace

### 1. Create the directory
```bash
mkdir -p apps/my-namespace
```

### 2. Create `namespace.yaml` with Helm values
```yaml
# apps/my-namespace/namespace.yaml
namespaceName: my-namespace

namespaceLabels:
  environment: production
  team: backend

resourceQuota:
  enabled: true
  hard:
    pods: "50"
    requests.cpu: "4"
    requests.memory: "8Gi"
    limits.cpu: "8"
    limits.memory: "16Gi"

networkPolicy:
  enabled: true
  allowDNS: true
  allowKubeSystem: true
  allowIngressController: true
  allowExternalEgress: true
```

### 3. Commit and push
```bash
git add apps/my-namespace/
git commit -m "Add my-namespace namespace"
git push
```

ArgoCD will automatically:
- Discover the `namespace.yaml` file
- Create Application `my-namespace-namespace`
- Deploy the namespace with configured resources
- Create admin and viewer ServiceAccounts
- Apply resource quotas and network policies

## Configuration Options

All values from the [isolated-namespace Helm chart](https://github.com/one-t/proxmox-argo-helm/tree/main/isolated-namespace):

**Required:**
- `namespaceName` - Namespace name

**Optional:**
- `namespaceLabels` - Custom labels
- `namespaceAnnotations` - Custom annotations
- `resourceQuota.enabled` - Enable quotas (default: true)
- `resourceQuota.hard.*` - Quota limits
- `networkPolicy.enabled` - Enable network policies (default: true)
- `networkPolicy.allowDNS` - Allow DNS (default: true)
- `networkPolicy.allowKubeSystem` - Allow kube-system (default: true)
- `networkPolicy.allowIngressController` - Allow ingress (default: true)
- `networkPolicy.allowExternalEgress` - Allow external traffic (default: true)
- `networkPolicy.allowEgressTo` - Additional allowed namespaces
- `serviceAccount.admin.*` - Admin SA config
- `serviceAccount.viewer.*` - Viewer SA config

## Examples

### Minimal (Using Defaults)
```yaml
# apps/staging/namespace.yaml
namespaceName: staging
```

### Production (Custom Quotas)
```yaml
# apps/production/namespace.yaml
namespaceName: production

namespaceLabels:
  environment: production
  criticality: high

resourceQuota:
  enabled: true
  hard:
    pods: "100"
    requests.cpu: "16"
    requests.memory: "32Gi"
    limits.cpu: "32"
    limits.memory: "64Gi"
```

### Isolated (Restricted Network)
```yaml
# apps/isolated/namespace.yaml
namespaceName: isolated

networkPolicy:
  enabled: true
  allowDNS: true
  allowKubeSystem: false
  allowIngressController: false
  allowExternalEgress: false
  allowEgressTo: []
```

## Notes

⚠️ **File must be `apps/NAMESPACE/namespace.yaml`** (not in subdirectories)

✅ **Namespace created before apps** (sync-wave: -1)

✅ **Match directory and namespace names** for clarity
