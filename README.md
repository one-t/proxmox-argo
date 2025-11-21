# Proxmox ArgoCD Repository

This repository contains Kubernetes manifests managed by ArgoCD for the Proxmox k3s cluster.

## Repository Structure

```
apps/
  hello-world/
    deployment.yaml    # Hello World nginx application
    ingress.yaml       # Traefik ingress configuration
```

## Applications

### Hello World

A simple nginx-based hello world application demonstrating the GitOps workflow.

**Access:**
- Via Traefik ingress: `http://terraform-k3s-hello-world.local` (or via gateway IP)
- Default route also configured for direct IP access

**Replicas:** 3 (distributed across workers)

## ArgoCD Configuration

This repository is configured in ArgoCD to automatically sync applications to the k3s cluster.

**Repository URL:** https://github.com/one-t/proxmox-argo
**Path:** `apps/`
**Sync Policy:** Automated with self-healing

## Making Changes

1. Update manifests in this repository
2. Commit and push changes
3. ArgoCD automatically detects changes and syncs to cluster
4. Monitor sync status in ArgoCD UI

## Infrastructure Details

- **Cluster:** k3s on Proxmox
- **Ingress Controller:** Traefik (k3s default)
- **Load Balancer:** HAProxy on gateway VM
- **GitOps:** ArgoCD
- **Storage:** Longhorn distributed block storage
