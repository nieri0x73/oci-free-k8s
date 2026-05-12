#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
REPO_URL="https://github.com/nieri0x73/oci-free-k8s"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── instala ArgoCD via Helm ───────────────────────────────────────────────────
helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || helm repo update argo
helm upgrade --install argocd argo/argo-cd \
  -n "$ARGOCD_NS" --create-namespace \
  -f "$SCRIPT_DIR/../gitops/bootstrap/argocd/values.yaml" \
  --wait

# ── credenciais do repositório (privado) ──────────────────────────────────────
read -rsp "GitHub token (deixe vazio se repo público): " GH_TOKEN; echo

if [[ -n "$GH_TOKEN" ]]; then
  kubectl create secret generic oci-free-k8s-repo \
    -n "$ARGOCD_NS" \
    --from-literal=type=git \
    --from-literal=url="$REPO_URL" \
    --from-literal=password="$GH_TOKEN" \
    --from-literal=username=git \
    --dry-run=client -o yaml | \
    kubectl label --local -f - "argocd.argoproj.io/secret-type=repository" --dry-run=client -o yaml | \
    kubectl apply -f -
fi

# ── aplica apps-of-apps ──────────────────────────────────────────────────────
kubectl apply -f "$SCRIPT_DIR/../gitops/bootstrap/apps-of-apps.yaml"

echo ""
echo "==> ArgoCD bootstrap completo!"
echo "    Senha inicial: $(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NS -o jsonpath='{.data.password}' | base64 -d)"
