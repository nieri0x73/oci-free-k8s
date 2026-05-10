#!/usr/bin/env bash
set -euo pipefail

VAULT_NS="security"
VAULT_POD="vault-0"

v() { kubectl exec -n "$VAULT_NS" "$VAULT_POD" -- vault "$@"; }

read -rsp "Root token: " TOKEN; echo
v login "$TOKEN"

v secrets enable -path=secret kv-v2         2>/dev/null || true
v auth enable kubernetes                     2>/dev/null || true
v write auth/kubernetes/config kubernetes_host="https://kubernetes.default.svc"

v policy write external-secrets - <<'EOF'
path "secret/data/*"     { capabilities = ["read"] }
path "secret/metadata/*" { capabilities = ["read", "list"] }
EOF

v write auth/kubernetes/role/external-secrets \
  bound_service_account_names="external-secrets" \
  bound_service_account_namespaces="external-secrets" \
  policies="external-secrets" \
  ttl="1h"

echo ""
echo "==> Vault configurado. Agora popule os secrets:"
echo "    kubectl exec -n $VAULT_NS $VAULT_POD -- vault kv put secret/<app> <key>=<value>"
