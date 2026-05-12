# OCI Free Kubernetes

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0?style=flat&logo=istio&logoColor=white)
![Vault](https://img.shields.io/badge/Vault-FFEC6E?style=flat&logo=vault&logoColor=black)
![Longhorn](https://img.shields.io/badge/Longhorn-5F224A?style=flat&logo=longhorn&logoColor=white)
![cert-manager](https://img.shields.io/badge/cert--manager-003B6F?style=flat&logo=letsencrypt&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=flat&logo=cloudflare&logoColor=white)
![Keycloak](https://img.shields.io/badge/Keycloak-4D4D4D?style=flat&logo=keycloak&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=flat&logo=postgresql&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-EA4B71?style=flat&logo=n8n&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat)

Production-grade Kubernetes cluster on OCI Always Free tier — GitOps with ArgoCD, Istio, Vault and Terraform.

## Stack

| Component | Description |
|-----------|-------------|
| [Kubernetes (OKE)](https://www.oracle.com/cloud/cloud-native/kubernetes-engine/) | Managed Kubernetes on OCI Always Free tier |
| [Terraform](terraform/) | Infrastructure provisioning (OKE, VCN, budgets) |
| [ArgoCD](gitops/bootstrap/argocd/) | GitOps continuous delivery |
| [Istio](gitops/config/istio/) | Service mesh, ingress gateway, mTLS |
| [Vault](gitops/config/vault/README.md) | Secrets management with OCI KMS auto-unseal |
| [External Secrets](gitops/config/external-secrets/README.md) | Sync Vault secrets to Kubernetes |
| [cert-manager](gitops/config/cert-manager/) | Automatic TLS certificates via Let's Encrypt |
| [External DNS](gitops/config/external-dns/README.md) | Automatic DNS records in Cloudflare |
| [Longhorn](gitops/config/longhorn/README.md) | Distributed block storage |
| [CloudNativePG](gitops/config/cloudnativepg/) | PostgreSQL operator |
| [Keycloak](gitops/config/keycloak/README.md) | Identity and Access Management (SSO) |
| [Vaultwarden](gitops/config/vaultwarden/README.md) | Self-hosted password manager |
| [n8n](gitops/config/n8n/) | Workflow automation |
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

## Getting Started

1. Provision infrastructure with Terraform
2. Install ArgoCD and apply the App of Apps
3. Bootstrap Vault and populate secrets
4. Point DNS to the NLB IP

Refer to each component's README for detailed configuration.
