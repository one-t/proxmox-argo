# GitHub Runner Secret

This file is NOT tracked in git. Create the secret manually:

## 1. Get your GitHub Personal Access Token

Go to: https://github.com/settings/tokens
- Click "Generate new token (classic)"
- Select scopes:
  - `repo` (Full control of private repositories)
  - `workflow` (Update GitHub Action workflows)
  - `admin:org` (if using org-level runner)

## 2. Create the secret on the cluster

SSH to the control plane and run:

```bash
kubectl create secret generic github-runner-secret \
  --from-literal=repo-url='https://github.com/one-t/your-repo-name' \
  --from-literal=token='ghp_YourPersonalAccessTokenHere' \
  -n default
```

### For organization-level runner:
```bash
kubectl create secret generic github-runner-secret \
  --from-literal=repo-url='https://github.com/one-t' \
  --from-literal=token='ghp_YourPersonalAccessTokenHere' \
  -n default
```

## 3. Verify the secret
```bash
kubectl get secret github-runner-secret -n default
```

## 4. Push to trigger ArgoCD sync
After creating the secret, the ApplicationSet will automatically create
the github-runner Application and deploy it.

## 5. Check runner status
```bash
kubectl get pods -l app=github-runner
kubectl logs -l app=github-runner -f
```

The runner should appear in your GitHub repo settings:
- Repo: https://github.com/one-t/your-repo/settings/actions/runners
- Org: https://github.com/organizations/one-t/settings/actions/runners

## Notes
- The runner requires Docker socket access (runs Docker-in-Docker)
- Default labels: `k3s`, `self-hosted`, `linux`, `x64`
- Resources: 512Mi-2Gi RAM, 0.5-2 CPU cores
