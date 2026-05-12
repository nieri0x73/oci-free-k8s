# OCI Free Kubernetes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.35.2-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![OCI](https://img.shields.io/badge/Cloud-Oracle_OCI-F80000?logo=oracle&logoColor=white)](https://www.oracle.com/cloud/)

Production-grade Kubernetes cluster on OCI Always Free tier — GitOps with ArgoCD, Istio, Vault and Terraform.

## Stack

| Component | Description |
|-----------|-------------|
| [Kubernetes (OKE)](https://www.oracle.com/cloud/cloud-native/kubernetes-engine/) | Managed Kubernetes on OCI Always Free tier |
| [Terraform](terraform/) | Infrastructure provisioning (OKE, VCN, budgets) |
| [Argo CD](gitops/bootstrap/argocd/) | GitOps continuous delivery |
| [Istio](gitops/config/istio/) | Service mesh, ingress gateway, mTLS |
| [HashiCorp Vault](gitops/config/vault/README.md) | Secrets management with OCI KMS auto-unseal |
| [External Secrets](gitops/config/external-secrets/README.md) | Sync Vault secrets to Kubernetes |
| [Cert Manager](gitops/config/cert-manager/) | Automatic TLS certificates via Let's Encrypt |
| [ExternalDNS](gitops/config/external-dns/README.md) | Automatic DNS records in Cloudflare |
| [Longhorn](gitops/config/longhorn/README.md) | Distributed block storage |
| [CloudNativePG](gitops/config/cloudnativepg/) | PostgreSQL operator |
| [Keycloak](gitops/config/keycloak/README.md) | Identity and Access Management (SSO) |
| [Vaultwarden](gitops/config/vaultwarden/README.md) | Self-hosted password manager |
| [N8N](gitops/config/n8n/) | Workflow automation |
| [Metrics Server](gitops/config/metrics-server/README.md) | Resource metrics for HPA and kubectl top |

## Structure

```
.
├── terraform/          # OCI infrastructure (OKE, VCN, networking, budgets)
├── gitops/
│   ├── bootstrap/      # ArgoCD install and App of Apps
│   ├── apps/           # ArgoCD Application manifests
│   └── config/         # Helm values and manifests per app
└── scripts/            # Vault bootstrap and helper scripts
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.15
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm) configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/docs/intro/install/) >= 3.10
- [ArgoCD CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/) (optional)

### 1. Infrastructure Setup

```bash
# Clone the repository
git clone https://github.com/nieri0x73/oci-free-k8s.git
cd oci-free-k8s

# Configure OCI credentials
oci setup config

# Create Terraform state bucket
oci os bucket create --name terraform-states --versioning Enabled --compartment-id <your-compartment-id>

# Deploy infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars    # Edit with your values
cp backend.hcl.example backend.hcl              # Edit with your OCI namespace and region
terraform init -backend-config=backend.hcl
terraform plan
terraform apply
```

### 2. Access the Cluster

```bash
# Kubeconfig is generated automatically by Terraform
export KUBECONFIG=$(pwd)/.kube.config
kubectl get nodes
```

### 3. Install ArgoCD

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace \
  -f gitops/bootstrap/argocd/values.yaml

# Apply the App of Apps
kubectl apply -f gitops/bootstrap/apps-of-apps.yaml
```

### 4. Bootstrap Vault

```bash
# Initialize and unseal Vault (OCI KMS auto-unseal)
bash scripts/vault-bootstrap.sh

# Populate secrets for each app
vault kv put secret/keycloak adminPassword='...' password='...'
vault kv put secret/vaultwarden ADMIN_TOKEN='...'
# See each app README for required secrets
```

### 5. DNS

DNS records are managed automatically by [External DNS](gitops/config/external-dns/README.md) via Cloudflare. Make sure your domain zone is already created in Cloudflare before deploying.

## Contributing

Contributions are welcome! Feel free to open issues or pull requests to improve this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [ArgoCD](https://argoproj.github.io/cd/)
- [Istio](https://istio.io/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- All the amazing open-source projects that make this possible
