# Actions Runner Controller Secret

## 1. Create a GitHub Personal Access Token (PAT)

Go to: https://github.com/settings/tokens

Click **"Generate new token (classic)"**

### Required scopes:
- `repo` (Full control of private repositories)
- `admin:org` (if using organization runners - optional)

For public repos only, you can use a Fine-grained token with:
- Repository permissions: `Actions: Read & Write`

## 2. Create the secret on the cluster

SSH to the control plane and run:

```bash
kubectl create secret generic controller-manager \
  --from-literal=github_token='ghp_YourPersonalAccessTokenHere' \
  -n actions-runner-system
```

## 3. Apply the configuration

The secret must exist BEFORE ArgoCD syncs the helm-release. Create it manually first, then let ArgoCD deploy the controller.

## 4. Verify installation

```bash
# Check controller is running
kubectl get pods -n actions-runner-system

# Check runner deployment
kubectl get runnerdeployment -n actions-runner-system

# Check runner pods
kubectl get pods -n actions-runner-system -l runner-deployment-name=k3s-runner

# View runner logs
kubectl logs -n actions-runner-system -l runner-deployment-name=k3s-runner
```

## 5. Verify in GitHub

The runner should appear in your repo settings:
https://github.com/one-t/proxmox-argo/settings/actions/runners

## Notes

- The controller watches for GitHub Actions jobs and automatically scales runners
- Runners are ephemeral - each job gets a fresh runner
- The controller requires the GitHub token to register/unregister runners
- You can scale runners with: `kubectl scale runnerdeployment k3s-runner --replicas=3 -n actions-runner-system`
