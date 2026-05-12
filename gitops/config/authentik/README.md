# Authentik

Identity and Access Management deployed via the [authentik](https://charts.goauthentik.io) Helm chart. Provides SSO (Single Sign-On) for all cluster applications via OpenID Connect.

## Access

| URL | Description |
|-----|-------------|
| `https://<your-domain>` | Authentik UI |
| `https://<your-domain>/if/admin/` | Admin console |

The `manifests/` directory contains the Istio Gateway, VirtualService and cert-manager Certificate. Update the domain in these files to match your own FQDN before deploying.

## Vault Secret

All sensitive configuration is stored in HashiCorp Vault at path `secret/authentik` and synced to the Kubernetes secret `authentik-credentials` via External Secrets Operator.

### Required keys

| Key | Description | Example |
|-----|-------------|---------|
| `AUTHENTIK_SECRET_KEY` | Secret key for cookie signing and user IDs — do not change after first install | `long-random-string` |
| `AUTHENTIK_BOOTSTRAP_PASSWORD` | Initial admin password | `your-admin-password` |
| `AUTHENTIK_BOOTSTRAP_TOKEN` | Initial API token | `your-api-token` |
| `AUTHENTIK_POSTGRESQL__PASSWORD` | PostgreSQL password for the internal database | `your-db-password` |

### Populating Vault

```bash
vault kv put secret/authentik \
  AUTHENTIK_SECRET_KEY='long-random-string-50-chars' \
  AUTHENTIK_BOOTSTRAP_PASSWORD='your-admin-password' \
  AUTHENTIK_BOOTSTRAP_TOKEN='your-api-token' \
  AUTHENTIK_POSTGRESQL__PASSWORD='your-db-password'
```

## Post-Deploy Configuration

After Authentik is running, configure the following via the admin console at `https://iam.nieri0x73.com/if/admin/`.

### 1. GitHub Social Login

Add GitHub as an OAuth2 source so users can log in with their GitHub account:

1. Create an OAuth App on GitHub: **Settings → Developer Settings → OAuth Apps → New OAuth App**
   - **Homepage URL**: `https://iam.nieri0x73.com`
   - **Callback URL**: `https://iam.nieri0x73.com/source/oauth/callback/github/`
2. In Authentik: **Directory → Federation & Social login → Create → GitHub OAuth Source**
   - Set **Consumer Key** and **Consumer Secret** from GitHub

### 2. SSO Clients

Configure OIDC providers for each application:

| Application | Provider Type | Redirect URI |
|-------------|--------------|--------------|
| ArgoCD | OIDC | `https://gitops.nieri0x73.com/auth/callback` |
| n8n | OIDC | `https://automation.nieri0x73.com/rest/oauth2-credential/callback` |
| Vaultwarden | OIDC | `https://pass.nieri0x73.com/identity/connect/authorize/callback` |

For each app: **Applications → Providers → Create → OAuth2/OpenID Provider**

> The vault-bootstrap.sh script handles Vault initialization and Kubernetes auth setup. Run it before populating the secrets above.
