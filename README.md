# Kubernetes Platform Engineering & Migration

> **About this repo:** my production work lives in private enterprise repositories, so this is a public reference build of the same patterns, written from scratch with sample data and placeholder account IDs.

A blueprint for running enterprise microservices on **Amazon EKS** and moving workloads onto it from legacy VM or script-based deployments. It includes the cluster (Terraform), a **standardized Helm chart** every service reuses, **RBAC and security hardening**, **autoscaling** and **Argo CD GitOps** delivery, with **Prometheus/Grafana** monitoring built in.

```
            Git (this repo)
                 │  app-of-apps
                 ▼
         ┌───────────────┐
         │    Argo CD    │──────────────┬──────────────────────┐
         └───────────────┘              │                      │
                 │ platform/            │ apps/                │
                 ▼                      ▼                      ▼
   kube-prometheus-stack,      orders-api (Helm)       payments-api (Helm)
   cluster-autoscaler,         ── charts/microservice ── one chart, many services
   metrics-server
                 ▲
         EKS cluster (terraform/)  — managed node groups, IRSA, private endpoint
```

## What's inside

| Path | Purpose |
|------|---------|
| `terraform/` | EKS cluster, managed node groups, IRSA roles and Argo CD bootstrap |
| `charts/microservice/` | A golden-path Helm chart: Deployment, Service, HPA, PDB, NetworkPolicy, ServiceAccount and ServiceMonitor |
| `gitops/root-app.yaml` | Argo CD app-of-apps entry point |
| `gitops/platform/` | Cluster add-ons: monitoring, autoscaler, metrics-server |
| `gitops/apps/` | Workloads, each just a `values` override of the shared chart |
| `rbac/` | Namespace-scoped developer and read-only roles |
| `policies/` | Pod Security Standards and default-deny network policy |
| `local/` | kind cluster, Argo CD bootstrap and a demo app for local runs |
| `docs/gitops-lab.md` | Hands-on experiments: drift, Git-driven change, rollback and debugging |
| `docs/migration-playbook.md` | Step-by-step process for moving legacy services onto the platform |

## Hardening defaults in the chart

- Non-root, read-only root filesystem, all Linux capabilities dropped, `RuntimeDefault` seccomp
- CPU and memory requests and limits, plus liveness, readiness and startup probes
- An HPA on CPU and memory, plus a PodDisruptionBudget for safe node drains
- A default-deny NetworkPolicy with explicit ingress allow-lists
- Topology spread across availability zones

## Run it free on your laptop (kind)

`./local/up.sh` creates a 3-node kind cluster, installs Argo CD and deploys the golden-path chart through GitOps. The drift, rollback and failure experiments are in [docs/gitops-lab.md](docs/gitops-lab.md).

## Quick start (AWS / EKS)

```bash
# 1. Cluster
cd terraform && terraform init && terraform apply

# 2. Bootstrap GitOps (Argo CD installed by Terraform)
kubectl apply -f gitops/root-app.yaml

# 3. Render a service locally
helm template orders charts/microservice -f gitops/apps/orders-api/values.yaml
```

## Tech

Kubernetes (EKS) · Helm · Argo CD · Docker · Terraform · AWS · Prometheus · Grafana
