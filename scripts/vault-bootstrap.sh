#!/usr/bin/env bash
set -euo pipefail

VAULT_POD="${VAULT_POD:-vault-0}"
VAULT_NS="${VAULT_NS:-security}"

vault_exec() {
  kubectl exec -n "$VAULT_NS" "$VAULT_POD" -- vault "$@"
}

# ── root token ────────────────────────────────────────────────────────────────
if [[ -z "${VAULT_ROOT_TOKEN:-}" ]]; then
  read -rsp "Root token: " VAULT_ROOT_TOKEN
  echo
fi

vault_exec login "$VAULT_ROOT_TOKEN"

# ── KV secrets engine ─────────────────────────────────────────────────────────
vault_exec secrets enable -path=secret kv-v2 2>/dev/null || echo "secret already enabled"

# ── Kubernetes auth ───────────────────────────────────────────────────────────
vault_exec auth enable kubernetes 2>/dev/null || echo "kubernetes auth already enabled"
vault_exec write auth/kubernetes/config kubernetes_host="https://kubernetes.default.svc"

# ── policy: external-secrets (read all app paths) ─────────────────────────────
vault_exec policy write external-secrets - <<'EOF'
path "secret/data/*" {
  capabilities = ["read"]
}
path "secret/metadata/*" {
  capabilities = ["read", "list"]
}
EOF

# ── role: external-secrets ────────────────────────────────────────────────────
vault_exec write auth/kubernetes/role/external-secrets \
  bound_service_account_names="external-secrets" \
  bound_service_account_namespaces="external-secrets" \
  policies="external-secrets" \
  ttl="1h"

# ── seed secrets (placeholders — edite antes de rodar) ────────────────────────
echo ""
echo "==> Criando secrets com placeholders. Edite os valores antes de rodar em produção."
echo ""

vault_exec kv put secret/cert-manager \
  token="CLOUDFLARE_API_TOKEN"

vault_exec kv put secret/external-dns \
  token="CLOUDFLARE_API_TOKEN"

vault_exec kv put secret/keycloak \
  admin-password="CHANGE_ME" \
  db-password="CHANGE_ME"

vault_exec kv put secret/postgres \
  username="postgres" \
  password="CHANGE_ME" \
  app-username="app" \
  app-password="CHANGE_ME"

vault_exec kv put secret/n8n \
  db-password="CHANGE_ME" \
  encryption-key="CHANGE_ME"

vault_exec kv put secret/vaultwarden \
  admin-token="CHANGE_ME" \
  db-password="CHANGE_ME"

echo ""
echo "==> Vault bootstrap completo!"
echo "    Lembre de atualizar os secrets com valores reais:"
echo "    kubectl exec -n $VAULT_NS $VAULT_POD -- vault kv put secret/<app> <key>=<value>"
