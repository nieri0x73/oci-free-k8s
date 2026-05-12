# Keycloak

Identity and Access Management deployed via the [bitnami/keycloak](https://charts.bitnami.com/bitnami) Helm chart. Provides SSO (Single Sign-On) for all cluster applications via OpenID Connect.

## Access

| URL | Description |
|-----|-------------|
| `https://<your-domain>` | Keycloak UI |
| `https://<your-domain>/admin` | Admin console |

The `manifests/` directory contains the Istio Gateway, VirtualService and cert-manager Certificate. Update the domain in these files to match your own FQDN before deploying.

## Vault Secret

All sensitive configuration is stored in HashiCorp Vault at path `secret/keycloak` and synced to the Kubernetes secret `keycloak-credentials` via External Secrets Operator.

### Required keys

| Key | Description | Example |
|-----|-------------|---------|
| `adminPassword` | Keycloak admin user password | `your-admin-password` |
| `password` | PostgreSQL password for the internal database | `your-db-password` |

### Populating Vault

```bash
vault kv put secret/keycloak \
  adminPassword='your-admin-password' \
  password='your-db-password'
```

## Post-Deploy Configuration

After Keycloak is running, configure the following via the admin console:

### 1. Create a Realm

Do not use the `master` realm for applications. Create a dedicated realm (e.g. `apps`).

### 2. Authentication Providers

By default, users log in with a local Keycloak username and password. You can create users directly in the realm under **Users → Add user**.

Optionally, you can add **GitHub as an Identity Provider** so users can log in with their GitHub account:

1. Create an OAuth App on GitHub: **Settings → Developer Settings → OAuth Apps → New OAuth App**
   - **Homepage URL**: `https://<your-keycloak-domain>`
   - **Callback URL**: `https://<your-keycloak-domain>/realms/<realm>/broker/github/endpoint`
2. Copy the **Client ID** and **Client Secret**
3. In Keycloak, go to **Identity Providers → GitHub** and fill in the values

Both methods can coexist — the login page will show the username/password form and a "Sign in with GitHub" button.

### 3. Create Clients

Create one client per application that will use SSO:

| Client ID | Application | Redirect URI |
|-----------|-------------|--------------|
| `vaultwarden` | Vaultwarden | `https://<vaultwarden-domain>/identity/connect/oidc-signin` |
| `n8n` | n8n | `https://<n8n-domain>/rest/oauth2-credential/callback` |
| `argocd` | ArgoCD | `https://<argocd-domain>/auth/callback` |

For each client:
1. Set **Client authentication** to `On`
2. Copy the **Client Secret** from the Credentials tab
3. Add the secret to Vault at the respective app path (e.g. `secret/vaultwarden` key `SSO_CLIENT_SECRET`)

### 4. Create Users

Create your user in the realm and assign roles as needed.
