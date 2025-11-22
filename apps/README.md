# App Directory Structure

Apps are automatically discovered and deployed by ArgoCD ApplicationSet.

## Directory Structure Convention

```
apps/
├── <namespace-name>/
│   ├── <app-name>/
│   │   ├── deployment.yaml
│   │   └── ingress.yaml
│   └── <another-app>/
│       └── deployment.yaml
└── <another-namespace>/
    └── <app-name>/
        └── deployment.yaml
```

## How It Works

1. **Namespace is derived from parent directory**: 
   - `apps/demo-apps/hello-world/` → deploys to `demo-apps` namespace
   - `apps/production/api/` → deploys to `production` namespace

2. **Application name is auto-generated**: 
   - Format: `<namespace>-<app-name>`
   - Example: `demo-apps-hello-world`

3. **No need to specify namespace in manifests**:
   - ArgoCD automatically applies resources to the correct namespace
   - Keep your manifests clean and portable

## Creating a New App

### 1. Create directory structure:
```bash
mkdir -p apps/my-namespace/my-app
```

### 2. Add Kubernetes manifests (NO namespace field needed):
```yaml
# apps/my-namespace/my-app/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  # NO namespace field needed!
spec:
  replicas: 2
  # ... rest of deployment
```

### 3. Commit and push:
```bash
git add apps/my-namespace/
git commit -m "Add my-app to my-namespace"
git push
```

### 4. ArgoCD automatically:
- Discovers the new app
- Creates Application `my-namespace-my-app`
- Deploys to `my-namespace` namespace

## Important Notes

⚠️ **Do NOT include `namespace:` in your manifests** - ArgoCD sets this automatically

✅ **Do create the namespace first** using a `.values.yaml` file in `namespaces/`

✅ **Do use resource requests/limits** when namespace has resource quotas

## Moving Apps Between Namespaces

Simply move the directory:
```bash
# Move app from demo-apps to production
git mv apps/demo-apps/my-app apps/production/my-app
git commit -m "Move my-app to production namespace"
git push
```

ArgoCD will:
1. Delete the app from `demo-apps` namespace
2. Create it in `production` namespace

## Examples

Current apps in this repo:

- `apps/demo-apps/hello-world/` → Application: `demo-apps-hello-world`
- `apps/demo-apps/cowsay-fortune/` → Application: `demo-apps-cowsay-fortune`
- `apps/demo-apps/nicolas-cage/` → Application: `demo-apps-nicolas-cage`
- `apps/demo-apps/screaming-into-void/` → Application: `demo-apps-screaming-into-void`
- `apps/demo-apps/cringe-meter/` → Application: `demo-apps-cringe-meter`

All deployed to the `demo-apps` namespace automatically!
