#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
REPO_URL="https://github.com/<your-username>/<your-repo>"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── install ArgoCD via Helm ───────────────────────────────────────────────────
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || helm repo update argo
helm upgrade --install argocd argo/argo-cd \
  -n "$ARGOCD_NS" --create-namespace \
  -f "$SCRIPT_DIR/../gitops/bootstrap/argocd/values.yaml" \
  --wait

# ── repository credentials (private repos only) ───────────────────────────────
read -rsp "GitHub token (leave empty if repo is public): " GH_TOKEN; echo

if [[ -n "$GH_TOKEN" ]]; then
  # NOTE: this creates a Kubernetes Secret directly as a bootstrap step.
  # Once Vault is running, migrate this secret to Vault and manage it via
  # External Secrets Operator instead.
  kubectl create secret generic argocd-repo-creds \
    -n "$ARGOCD_NS" \
    --from-literal=type=git \
    --from-literal=url="$REPO_URL" \
    --from-literal=password="$GH_TOKEN" \
    --from-literal=username=git \
    --dry-run=client -o yaml | \
    kubectl label --local -f - "argocd.argoproj.io/secret-type=repository" --dry-run=client -o yaml | \
    kubectl apply -f -
fi

# ── apply App of Apps ─────────────────────────────────────────────────────────
kubectl apply -f "$SCRIPT_DIR/../gitops/bootstrap/apps-of-apps.yaml"

echo ""
echo "==> ArgoCD bootstrap complete!"
echo "    Initial password: $(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NS -o jsonpath='{.data.password}' | base64 -d)"
