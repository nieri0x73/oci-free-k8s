#!/usr/bin/env bash
set -euo pipefail

VAULT_NS="security"
VAULT_POD="vault-0"

v() { kubectl exec -n "$VAULT_NS" "$VAULT_POD" -- vault "$@"; }

# ── wait for Vault pod to exist and be running ───────────────────────────────
echo "==> Waiting for Vault pod to be running..."
kubectl wait --for=condition=initialized pod/"$VAULT_POD" -n "$VAULT_NS" --timeout=120s

# ── initialize Vault (first time only) ───────────────────────────────────────
if v status -format=json 2>/dev/null | grep -q '"initialized":false'; then
  echo "==> Initializing Vault..."
  kubectl exec -n "$VAULT_NS" "$VAULT_POD" -- vault operator init \
    -recovery-shares=5 \
    -recovery-threshold=3 \
    -format=json | tee vault-init.json
  echo "==> vault-init.json saved. Keep it safe — do NOT commit this file."
  TOKEN=$(jq -r '.root_token' vault-init.json)
else
  echo "==> Vault already initialized."
  read -rsp "Root token: " TOKEN; echo
fi

v login "$TOKEN"

# ── enable secrets engine and kubernetes auth ─────────────────────────────────
v secrets enable -path=secret kv-v2         2>/dev/null || true
v auth enable kubernetes                     2>/dev/null || true
v write auth/kubernetes/config kubernetes_host="https://kubernetes.default.svc"

# ── policy for External Secrets Operator ─────────────────────────────────────
v policy write external-secrets - <<'EOF'
path "secret/data/*"     { capabilities = ["read"] }
path "secret/metadata/*" { capabilities = ["read", "list"] }
EOF

v write auth/kubernetes/role/external-secrets \
  bound_service_account_names="external-secrets" \
  bound_service_account_namespaces="security" \
  policies="external-secrets" \
  ttl="1h"

echo ""
echo "==> Vault configured. Now populate secrets for each app:"
echo "    kubectl exec -n $VAULT_NS $VAULT_POD -- vault kv put secret/<app> <key>=<value>"
echo ""
echo "    See each app README for required secret keys."
