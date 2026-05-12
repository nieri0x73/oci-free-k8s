# OCI Free Kubernetes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
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
