#!/bin/bash
# Generate namespace Application manifests from simplified values files
# Usage: ./generate-namespaces.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACES_DIR="$SCRIPT_DIR/namespaces"
OUTPUT_DIR="$NAMESPACES_DIR/generated"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Clean old generated files
rm -f "$OUTPUT_DIR"/*.yaml

echo "Generating namespace Applications from values files..."

# Process each .values.yaml file
for values_file in "$NAMESPACES_DIR"/*.values.yaml; do
  if [ ! -f "$values_file" ]; then
    continue
  fi
  
  filename=$(basename "$values_file" .values.yaml)
  echo "  Processing: $filename"
  
  # Read values using yq (or fall back to basic parsing)
  if command -v yq &> /dev/null; then
    name=$(yq eval '.name' "$values_file")
    project=$(yq eval '.project // .name' "$values_file")
    
    # Read labels
    env_label=$(yq eval '.labels.environment // "default"' "$values_file")
    team_label=$(yq eval '.labels.team // ""' "$values_file")
    
    # Read quota
    pods=$(yq eval '.quota.pods // "30"' "$values_file")
    cpu=$(yq eval '.quota.cpu // "2"' "$values_file")
    memory=$(yq eval '.quota.memory // "4Gi"' "$values_file")
    
    # Read network
    allow_internet=$(yq eval '.network.allowInternet // true' "$values_file")
  else
    # Fallback: basic grep parsing
    name=$(grep '^name:' "$values_file" | awk '{print $2}')
    project=$name
    env_label=$(grep 'environment:' "$values_file" | awk '{print $2}' || echo "default")
    pods=$(grep 'pods:' "$values_file" | awk '{print $2}' || echo "30")
    cpu=$(grep 'cpu:' "$values_file" | awk '{print $2}' | tr -d '"' || echo "2")
    memory=$(grep 'memory:' "$values_file" | awk '{print $2}' | tr -d '"' || echo "4Gi")
    allow_internet="true"
  fi
  
  # Generate Application manifest
  cat > "$OUTPUT_DIR/$name.yaml" <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $name-namespace
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
spec:
  project: $project
  
  source:
    repoURL: https://github.com/one-t/proxmox-argo-helm.git
    targetRevision: main
    path: isolated-namespace
    helm:
      values: |
        namespaceName: $name
        
        namespaceLabels:
          environment: $env_label
          managed-by: argocd
$([ -n "$team_label" ] && echo "          team: $team_label")
        
        resourceQuota:
          enabled: true
          hard:
            pods: "$pods"
            requests.cpu: "$cpu"
            requests.memory: "$memory"
            limits.cpu: "$(echo "$cpu * 2" | bc)"
            limits.memory: "$(echo "$memory" | sed 's/Gi/*2Gi/' | bc || echo "8Gi")"
            persistentvolumeclaims: "10"
            services: "20"
            configmaps: "50"
            secrets: "50"
        
        networkPolicy:
          enabled: true
          allowDNS: true
          allowKubeSystem: true
          allowIngressController: true
          allowExternalEgress: $allow_internet
        
        serviceAccount:
          admin:
            create: true
            name: namespace-admin
            createToken: true
          viewer:
            create: true
            name: namespace-viewer
            createToken: true
  
  destination:
    server: https://kubernetes.default.svc
    namespace: $name
  
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
EOF

  echo "    ✓ Generated: $OUTPUT_DIR/$name.yaml"
done

echo ""
echo "Generated $(ls -1 "$OUTPUT_DIR"/*.yaml 2>/dev/null | wc -l | tr -d ' ') namespace Application(s)"
echo ""
echo "To apply:"
echo "  git add namespaces/generated/"
echo "  git commit -m 'Update namespace Applications'"
echo "  git push"
