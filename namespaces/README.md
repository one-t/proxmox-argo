# Simplified Namespace Definitions

Instead of writing full Application manifests, just create simple values files!

## Quick Start

### 1. Create a namespace values file:

**`namespaces/my-app.values.yaml`:**
```yaml
name: my-app
labels:
  environment: production
quota:
  pods: 20
  cpu: "4"
  memory: "8Gi"
```

### 2. Update the ApplicationSet

The `namespaces` ApplicationSet in cloud-init should use this pattern:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: namespaces
  namespace: argocd
spec:
  generators:
  - git:
      repoURL: https://github.com/one-t/proxmox-argo.git
      revision: main
      files:
      - path: "namespaces/*.values.yaml"
  template:
    metadata:
      name: '{{name}}-namespace'
      annotations:
        argocd.argoproj.io/sync-wave: "-1"
    spec:
      project: '{{project}}'  # Defaults to {{name}} if not set
      source:
        repoURL: https://github.com/one-t/proxmox-argo-helm.git
        targetRevision: main
        path: isolated-namespace
        helm:
          values: |
            namespaceName: {{name}}
            namespaceLabels:
              environment: {{labels.environment}}
              managed-by: argocd
            resourceQuota:
              enabled: true
              hard:
                pods: "{{quota.pods}}"
                requests.cpu: "{{quota.cpu}}"
                requests.memory: "{{quota.memory}}"
                limits.cpu: "{{quota.cpuLimit}}"
                limits.memory: "{{quota.memoryLimit}}"
            networkPolicy:
              enabled: true
              allowExternalEgress: {{network.allowInternet}}
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{name}}'
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## Default Values

The Helm chart has sensible defaults, so you only need to specify what you want to change:

### Minimal Example (uses all defaults):
```yaml
name: simple-app
```

### Common Example:
```yaml
name: my-backend
labels:
  environment: production
  team: backend
quota:
  pods: 50
  cpu: "8"
  memory: "16Gi"
```

### Advanced Example:
```yaml
name: isolated-db
labels:
  environment: production
  workload: stateful
quota:
  pods: 10
  cpu: "16"
  memory: "64Gi"
network:
  allowInternet: false
  allowFromNamespaces:
    - name: backend
      labels:
        needs-database: "true"
```

## Benefits

1. **90% less boilerplate** - just set the values you care about
2. **Type-safe** - ApplicationSet validates the values
3. **Git-driven** - commit values file, ArgoCD creates namespace
4. **Consistent** - all namespaces use same Helm chart
5. **Discoverable** - easy to see all namespaces in one directory

## Migration

To migrate existing namespace Applications:

```bash
# 1. Extract values from existing Application
kubectl get application demo-apps-namespace -n argocd -o yaml > old.yaml

# 2. Create simplified values file
cat > namespaces/demo-apps.values.yaml <<EOF
name: demo-apps
labels:
  environment: demo
quota:
  pods: 30
  cpu: "2"
  memory: "4Gi"
EOF

# 3. Delete old Application (ApplicationSet will recreate it)
kubectl delete application demo-apps-namespace -n argocd

# 4. Commit and push
git add namespaces/demo-apps.values.yaml
git commit -m "Migrate to simplified namespace definition"
git push
```
