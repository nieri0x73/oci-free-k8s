#!/usr/bin/env bash
set -euo pipefail

ARGOCD_NS="argocd"
REPO_URL="https://github.com/nieri0x73/oci-free-k8s"

# ── instala ArgoCD ────────────────────────────────────────────────────────────
kubectl create namespace "$ARGOCD_NS" 2>/dev/null || true
kubectl apply -n "$ARGOCD_NS" -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "==> Aguardando ArgoCD..."
kubectl wait --for=condition=available deploy/argocd-server -n "$ARGOCD_NS" --timeout=120s

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
kubectl apply -f gitops/bootstrap/apps-of-apps.yaml

echo ""
echo "==> ArgoCD bootstrap completo!"
echo "    Senha inicial: $(kubectl get secret argocd-initial-admin-secret -n $ARGOCD_NS -o jsonpath='{.data.password}' | base64 -d)"
