# PostgreSQL

PostgreSQL cluster deployed via the [CloudNativePG cluster](https://cloudnative-pg.github.io/charts) Helm chart, managed by the CloudNativePG operator.

## How It Works

The cluster chart creates a `Cluster` custom resource that the CloudNativePG operator uses to provision and manage PostgreSQL pods, replication, and credentials.

## No Vault Secret Required

Credentials are generated automatically by the CloudNativePG operator and stored in Kubernetes secrets within the `databases` namespace:

| Secret | Description |
|--------|-------------|
| `postgres-cluster-app` | Credentials for the `app` database user |
| `postgres-cluster-superuser` | Superuser credentials |

Each secret contains `username`, `password`, `host`, `port`, `uri` and `jdbc-uri` ready to use.

## Connecting to the Database

Use the read-write service for writes and the read-only service for reads:

| Service | Description |
|---------|-------------|
| `postgres-cluster-rw.databases` | Read-write (primary) |
| `postgres-cluster-ro.databases` | Read-only (replicas) |

## Controlling Credentials via Vault

To use a custom password instead of the auto-generated one, populate `secret/postgres` in Vault before the cluster is first created:

```bash
vault kv put secret/postgres \
  username='app' \
  password='your-password'
```

Then reference it in `values.yaml`:

```yaml
cluster:
  bootstrap:
    initdb:
      database: app
      owner: app
      secret:
        name: postgres-credentials
```

> Note: credentials can only be set during initial cluster creation. Changing them after requires recreating the cluster.
