# Rancher

Rancher multi-cluster Kubernetes management platform.

## Access

Rancher will be available at: http://rancher.local

You'll need to add this to your `/etc/hosts` file:
```
10.99.0.1  rancher.local
```

Or access via the gateway IP directly on port 80/443.

## Initial Setup

1. The bootstrap password is set to `BOOTSTRAP_PASSWORD_PLACEHOLDER` in the ConfigMap
2. On first access, you'll be prompted to:
   - Set a new admin password
   - Accept the Rancher Server URL
3. The local k3s cluster will be automatically imported

## Components Installed

- **cert-manager**: Certificate management (required by Rancher)
- **Rancher**: Multi-cluster management UI
- **Ingress**: Access via rancher.local hostname

## Resources

- **Rancher**: 500m-1000m CPU, 1-2Gi RAM
- **cert-manager**: Minimal resources (runs 3 pods)

## Notes

- Uses self-signed certificates (rancher-generated)
- Single replica (sufficient for single-node cluster)
- Bootstrap password should be changed on first login
- Manages the local k3s cluster automatically
