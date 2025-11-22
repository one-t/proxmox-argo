# Bootstrap Directory

This directory contains the foundational ArgoCD Applications that create projects and namespaces.

## Purpose

The bootstrap Application (created by cloud-init) monitors this directory and applies all manifests within it. This creates the necessary AppProjects and namespace Applications before any apps are deployed.

## Contents

Each file should contain:
1. **AppProject** - Defines the ArgoCD project with source repos and allowed destinations
2. **Namespace Application** - ArgoCD Application that deploys the Helm chart to create the namespace

## File Structure

Each namespace should have its own file:

```yaml
# bootstrap/my-namespace.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-namespace
  namespace: argocd
spec:
  description: My Namespace Project
  sourceRepos:
  - 'https://github.com/one-t/proxmox-argo.git'
  - 'https://github.com/one-t/proxmox-argo-helm.git'
  - '*'
  destinations:
  - namespace: my-namespace
    server: https://kubernetes.default.svc
  clusterResourceWhitelist:
  - group: ''
    kind: Namespace
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-namespace-namespace
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
  project: my-namespace
  source:
    repoURL: https://github.com/one-t/proxmox-argo-helm.git
    targetRevision: main
    path: isolated-namespace
    helm:
      valuesObject:
        namespaceName: my-namespace
        namespaceLabels:
          environment: production
        resourceQuota:
          enabled: true
          hard:
            pods: "50"
            requests.cpu: "4"
            requests.memory: "8Gi"
        networkPolicy:
          enabled: true
          allowDNS: true
          allowKubeSystem: true
          allowIngressController: true
          allowExternalEgress: true
  destination:
    server: https://kubernetes.default.svc
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Adding a New Namespace

1. Create a new file: `bootstrap/my-namespace.yaml`
2. Copy the structure from an existing file (e.g., `staging.yaml`)
3. Update:
   - Project name
   - Namespace name
   - Resource quotas
   - Network policy settings
4. Commit and push
5. ArgoCD will automatically apply it via the bootstrap Application

## Notes

- The AppProject restricts which repositories and namespaces the project can deploy to
- The namespace Application uses sync-wave `-1` to ensure it's created before apps
- All values are inline (valuesObject) rather than referencing external files
- The bootstrap Application itself uses the `default` project
