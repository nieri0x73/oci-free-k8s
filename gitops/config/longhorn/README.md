# Longhorn

Distributed block storage for Kubernetes deployed via the [longhorn](https://charts.longhorn.io) Helm chart. Provides persistent volumes with replication across nodes.

## Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| `defaultReplicaCount` | `2` | Each volume has 2 copies, one per node |
| `storageMinimalAvailablePercentage` | `10` | Alert when disk has less than 10% free |
| `defaultClass` | `true` | Longhorn is the default StorageClass |
| `defaultClassReplicaCount` | `2` | Default replicas for new PVCs |
| `longhornUI.replicas` | `1` | Single UI pod to save resources |
| `metrics.serviceMonitor.enabled` | `true` | Exposes metrics for Prometheus |

## Deleting Nodes

When deleting a node (e.g. scaling down the node pool via Terraform), make sure to evict all Longhorn replicas from that node first via the Longhorn UI or CLI, otherwise the node deletion may hang waiting for volume detachment.

## Backup (Optional)

Longhorn supports backup to any S3-compatible object storage, including OCI Object Storage.

To enable, add the following to `values.yaml`:

```yaml
defaultBackupStore:
  backupTarget: s3://<bucket-name>@<region>/
  backupTargetCredentialSecret: longhorn-backup-secret
```

And create a Kubernetes secret with the credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: longhorn-backup-secret
  namespace: longhorn-system
type: Opaque
stringData:
  AWS_ACCESS_KEY_ID: <oci-access-key>
  AWS_SECRET_ACCESS_KEY: <oci-secret-key>
  AWS_ENDPOINTS: https://<namespace>.compat.objectstorage.<region>.oraclecloud.com
```

Then configure recurring backup jobs via the Longhorn UI under **Recurring Jobs**.
