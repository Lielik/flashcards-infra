# ☁️ Flashcards Infrastructure - Terraform Repository

Infrastructure as Code (IaC) repository for deploying the Flashcards application on AWS using Terraform. This repository provisions a complete EKS cluster with networking, security, monitoring, and GitOps capabilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Terraform Modules](#terraform-modules)
- [Configuration](#configuration)
- [Deployment Guide](#deployment-guide)
- [Monitoring & Logging](#monitoring--logging)
- [Cost Management](#cost-management)
- [Troubleshooting](#troubleshooting)
- [Cleanup](#cleanup)

## 🎯 Overview

This repository implements a production-ready Kubernetes infrastructure on AWS using Terraform best practices:

- **Modular Design**: Custom Terraform modules for reusability and maintainability
- **Multi-Environment Support**: Separate configurations for dev/staging/prod
- **Security First**: Private subnets, IAM roles, encrypted secrets
- **Cost Optimized**: Right-sized resources, autoscaling, easy teardown
- **Observability**: Integrated monitoring (Prometheus/Grafana) and logging (EFK)
- **GitOps Ready**: ArgoCD pre-configured for continuous deployment

### What Gets Provisioned

- **Networking**: VPC, public/private subnets, NAT Gateway, Internet Gateway
- **Compute**: EKS cluster with managed node group (t3a.medium instances)
- **Security**: IAM roles, security groups, OIDC provider for IRSA
- **Ingress**: NGINX Ingress Controller with Load Balancer
- **GitOps**: ArgoCD for application deployment
- **Monitoring**: Prometheus + Grafana stack
- **Logging**: Elasticsearch, Fluent Bit, Kibana (EFK stack)
- **Certificate Management**: cert-manager for TLS automation
- **Secret Management**: Sealed Secrets controller
---
## 🏗 Architecture

### AWS Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                                   │
│  Region: ap-south-1                                                      │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │  VPC: 10.0.0.0/16                                                │   │
│  │                                                                   │   │
│  │  ┌───────────────────────┐  ┌───────────────────────┐          │   │
│  │  │  AZ: ap-south-1a      │  │  AZ: ap-south-1b      │          │   │
│  │  │                       │  │                       │          │   │
│  │  │  ┌─────────────────┐ │  │  ┌─────────────────┐ │          │   │
│  │  │  │ Public Subnet   │ │  │  │ Public Subnet   │ │          │   │
│  │  │  │ 10.0.0.0/24     │ │  │  │ 10.0.1.0/24     │ │          │   │
│  │  │  │                 │ │  │  │                 │ │          │   │
│  │  │  │  NAT Gateway    │ │  │  │                 │ │          │   │
│  │  │  │  NLB (Ingress)  │ │  │  │                 │ │          │   │
│  │  │  └────────┬────────┘ │  │  └─────────────────┘ │          │   │
│  │  │           │           │  │                       │          │   │
│  │  │  ┌────────▼────────┐ │  │  ┌─────────────────┐ │          │   │
│  │  │  │ Private Subnet  │ │  │  │ Private Subnet  │ │          │   │
│  │  │  │ 10.0.100.0/24   │ │  │  │ 10.0.101.0/24   │ │          │   │
│  │  │  │                 │ │  │  │                 │ │          │   │
│  │  │  │  EKS Node 1     │ │  │  │  EKS Node 2-3   │ │          │   │
│  │  │  │  (t3a.medium)   │ │  │  │  (t3a.medium)   │ │          │   │
│  │  │  └─────────────────┘ │  │  └─────────────────┘ │          │   │
│  │  └───────────────────────┘  └───────────────────────┘          │   │
│  │                                                                 │   │
│  │  Internet Gateway ──┐                                          │   │
│  └─────────────────────┼──────────────────────────────────────────┘   │
│                        │                                               │
│  ┌─────────────────────┼──────────────────────────────────────────┐   │
│  │  EKS Control Plane  │                                           │   │
│  │  (AWS Managed)      │                                           │   │
│  └─────────────────────┼──────────────────────────────────────────┘   │
│                        │                                               │
│  ┌─────────────────────▼──────────────────────────────────────────┐   │
│  │  ECR (Container Registry)                                       │   │
│  │  - flashcards-app                                               │   │
│  │  - flashcards-nginx                                             │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────┐    │
│  │  S3 (Terraform State)                                          │    │
│  │  Bucket: tfstate-flashcards                                    │    │
│  └───────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘

        Internet
           ▲
           │
    ┌──────▼──────┐
    │   Route 53  │  (Optional - Bonus)
    │  DNS: *.app.dns │
    └─────────────┘
```

### Kubernetes Architecture

```
┌──────────────────── EKS Cluster ────────────────────────┐
│                                                          │
│  Namespaces:                                             │
│                                                          │
│  ┌─────── argocd ────────┐                              │
│  │  - ArgoCD Server      │  ← GitOps Controller         │
│  │  - Repo Server        │                              │
│  │  - ApplicationSet     │                              │
│  └───────────────────────┘                              │
│                                                          │
│  ┌─────── apps ──────────┐                              │
│  │  - Flask API (x2)     │  ← Your Application          │
│  │  - NGINX (x2)         │                              │
│  │  - MongoDB (x1)       │                              │
│  └───────────────────────┘                              │
│                                                          │
│  ┌──── ingress-nginx ────┐                              │
│  │  - Ingress Controller │  ← Entry Point               │
│  │  - NLB Service        │                              │
│  └───────────────────────┘                              │
│                                                          │
│  ┌──── monitoring ───────┐                              │
│  │  - Prometheus         │  ← Metrics Collection        │
│  │  - Grafana            │  ← Visualization             │
│  │  - Alertmanager       │                              │
│  └───────────────────────┘                              │
│                                                          │
│  ┌───── logging ─────────┐                              │
│  │  - Elasticsearch      │  ← Log Storage               │
│  │  - Fluent Bit         │  ← Log Collection            │
│  │  - Kibana             │  ← Log Visualization         │
│  └───────────────────────┘                              │
│                                                          │
│  ┌──── cert-manager ─────┐                              │
│  │  - cert-manager       │  ← TLS Automation            │
│  │  - ClusterIssuer      │                              │
│  └───────────────────────┘                              │
│                                                          │
│  ┌──── kube-system ──────┐                              │
│  │  - CoreDNS            │  ← DNS Resolution            │
│  │  - kube-proxy         │                              │
│  │  - AWS EBS CSI        │  ← Persistent Volumes        │
│  │  - Sealed Secrets     │  ← Secret Encryption         │
│  └───────────────────────┘                              │
└──────────────────────────────────────────────────────────┘
```
---
## 📁 Repository Structure

```
.
├── main.tf                      # Root module - orchestrates all components
├── variables.tf                 # Input variable declarations
├── outputs.tf                   # Output values (cluster info, commands)
├── provider.tf                  # Provider configuration (AWS, K8s, Helm)
├── Makefile                     # Convenient shortcuts for Terraform commands
│
├── env/                         # Environment-specific configurations
│   ├── dev.tfvars              # Development environment values
│   └── dev.backend.hcl         # S3 backend configuration for dev
│
├── modules/                     # Custom Terraform modules
│   ├── network/                # VPC, subnets, NAT, IGW
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── iam/                    # IAM roles and policies
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks/                    # EKS cluster and node group
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── eks-infra/              # Kubernetes infrastructure components
│   │   ├── main.tf             # ArgoCD, Ingress, Sealed Secrets
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── argocd/
│   │   │   └── apps-applicationset.yaml
│   │   ├── ingress-nginx/
│   │   │   └── values.yaml
│   │   └── certs/              # Sealed Secrets key pair
│   │       ├── tls.crt
│   │       └── tls.key
│   │
│   └── monitoring/             # Observability stack
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── helm-values/
│           ├── prometheus-values.yaml
│           ├── elasticsearch-values.yaml
│           ├── fluent-bit-values.yaml
│           └── kibana-values.yaml
│
├── dashboards/                  # Grafana dashboards (JSON)
│   └── monitoring/
│       ├── dashboard.png
│       └── Infrastructure & Performance.json
│
└── aws-infrastructure-diagram.png  # Architecture diagram
```
---
## ✅ Prerequisites

### Required Tools

Install these tools before proceeding:

```bash
# Terraform (>= 1.5.0)
wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip
unzip terraform_1.9.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# kubeseal (for sealed secrets)
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-0.24.0-linux-amd64.tar.gz
tar xfz kubeseal-0.24.0-linux-amd64.tar.gz
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

### AWS Account Setup

1. **AWS Account**: Active AWS account with appropriate permissions
2. **IAM User/Role**: With permissions for:
   - EC2, VPC, EKS
   - IAM (for role creation)
   - ECR (already exists)
   - S3 (for state storage)

3. **AWS Credentials Configuration**:
   ```bash
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Default region: ap-south-1
   # Default output format: json
   ```

4. **S3 Bucket for State** (create manually before first run):
   ```bash
   aws s3 mb s3://tfstate-flashcards --region ap-south-1
   aws s3api put-bucket-versioning \
     --bucket tfstate-flashcards \
     --versioning-configuration Status=Enabled
   ```

### ECR Repository

The application expects these ECR repositories to already exist:

```bash
# Verify repositories exist
aws ecr describe-repositories --repository-names flashcards-app flashcards-nginx
```
---
## 🚀 Quick Start

### Initial Deployment

```bash
# 1. Clone the repository
git clone <your-infra-repo-url>
cd flashcards-infrastructure

# 2. Initialize Terraform with backend configuration
make init
# Or: terraform init -backend-config=env/dev.backend.hcl

# 3. Review the execution plan
make plan
# Or: terraform plan -var-file=env/dev.tfvars

# 4. Apply the infrastructure
make apply
# Or: terraform apply -var-file=env/dev.tfvars

# 5. Configure kubectl
aws eks update-kubeconfig --name portfolio-dev-eks --region ap-south-1

# 6. Verify cluster access
kubectl get nodes
kubectl get pods --all-namespaces
```

### Daily Workflow

```bash
# Start of day: Provision infrastructure
make apply

# End of day: Destroy infrastructure to save costs
make destroy
```
---
## 🔧 Terraform Modules

### Module 1: Network (`modules/network/`)

**Purpose**: Creates the foundational networking layer for the EKS cluster.

**Resources Created**:
- **VPC**: Isolated network with CIDR 10.0.0.0/16
- **Public Subnets**: 2 subnets across AZs (10.0.0.0/24, 10.0.1.0/24)
  - For NAT Gateway, Load Balancers
  - Tagged for Kubernetes external ELB discovery
- **Private Subnets**: 2 subnets across AZs (10.0.100.0/24, 10.0.101.0/24)
  - For EKS worker nodes
  - Tagged for Kubernetes internal ELB discovery
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Gateway**: Allows private subnet egress to internet
- **Route Tables**: Separate routing for public and private subnets

**Key Variables**:
```hcl
vpc_cidr   = "10.0.0.0/16"
az_count   = 2
enable_nat = true
```

**Outputs**:
- `vpc_id`: VPC identifier
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs

### Module 2: IAM (`modules/iam/`)

**Purpose**: Creates IAM roles and policies for EKS cluster and worker nodes.

**Resources Created**:

1. **EKS Cluster Role**:
   - Attached policies:
     - `AmazonEKSClusterPolicy`
     - `AmazonEKSVPCResourceController`
   - Allows EKS to manage AWS resources

2. **EKS Node Role**:
   - Attached policies:
     - `AmazonEKSWorkerNodePolicy`
     - `AmazonEC2ContainerRegistryReadOnly`
     - `AmazonEKS_CNI_Policy`
   - Allows worker nodes to join cluster and pull images

3. **ALB Controller Role** (IRSA):
   - Uses OIDC provider for service account authentication
   - Allows AWS Load Balancer Controller to manage ALBs/NLBs
   - Trust policy restricts to specific service account

**Key Features**:
- **IRSA (IAM Roles for Service Accounts)**: Pods can assume IAM roles
- **Least Privilege**: Only necessary permissions granted
- **Service Account Binding**: Roles linked to Kubernetes service accounts

**Outputs**:
- `cluster_role_arn`: EKS cluster IAM role ARN
- `node_role_arn`: Worker node IAM role ARN

### Module 3: EKS (`modules/eks/`)

**Purpose**: Provisions the EKS cluster and managed node group.

**Resources Created**:

1. **EKS Cluster**:
   - Kubernetes version: Latest stable (managed by AWS)
   - Control plane in AWS-managed VPC
   - Endpoint access: Public + Private
   - Deployed in private subnets

2. **OIDC Provider**:
   - Enables IRSA (IAM Roles for Service Accounts)
   - Required for AWS Load Balancer Controller
   - Thumbprint validated

3. **Managed Node Group**:
   - Instance type: t3a.medium
   - Capacity: 2-3 nodes (starts at 3)
   - Capacity type: ON_DEMAND
   - AMI: Amazon Linux 2 (EKS-optimized)
   - Deployed in private subnets

4. **EBS CSI Driver Addon**:
   - Enables persistent volumes
   - IAM role for service account
   - Version: v1.50.1

**Key Variables**:
```hcl
instance_types = ["t3a.medium"]
min_size       = 2
desired_size   = 3
max_size       = 3
capacity_type  = "ON_DEMAND"
```

**Outputs**:
- `cluster_name`: EKS cluster name
- `cluster_endpoint`: API server endpoint
- `cluster_ca`: Certificate authority data
- `oidc_provider_arn`: OIDC provider ARN for IRSA

### Module 4: EKS Infrastructure (`modules/eks-infra/`)

**Purpose**: Deploys Kubernetes-level infrastructure components using Helm.

**Components Deployed**:

1. **Sealed Secrets Controller**:
   - Namespace: `kube-system`
   - Pre-configured with TLS certificate (from `certs/`)
   - Enables encrypted secrets in Git

2. **ArgoCD**:
   - Namespace: `argocd`
   - Version: 8.6.1
   - Components: Server, Repo Server, Application Controller
   - Auto-sync enabled for GitOps
   - Connected to GitOps repository

3. **NGINX Ingress Controller**:
   - Namespace: `ingress-nginx`
   - Type: Network Load Balancer (NLB)
   - Replicas: 2 (high availability)
   - Autoscaling: 2-6 replicas based on CPU/memory

4. **AWS Load Balancer Controller**:
   - Namespace: `kube-system`
   - Manages ALB/NLB from Ingress resources
   - Uses IRSA for AWS API calls

5. **ArgoCD ApplicationSet**:
   - Automatically deploys applications from GitOps repo
   - Wave-based deployment:
     - Wave 0: cert-manager (platform)
     - Wave 2: flashcards (application)

**Key Configuration**:
```yaml
# ApplicationSet deploys:
- cert-manager (namespace: cert-manager)
- flashcards (namespace: apps)
```

**Outputs**:
- `argocd_namespace`: ArgoCD namespace
- `gitops_repo_url`: GitOps repository URL
- `argocd_admin_password_command`: Command to retrieve admin password

### Module 5: Monitoring (`modules/monitoring/`)

**Purpose**: Deploys observability stack for metrics and logs.

**Components Deployed**:

1. **Prometheus Stack** (kube-prometheus-stack):
   - **Prometheus**: Metrics collection and storage (10Gi persistent volume)
   - **Grafana**: Metrics visualization
   - **Alertmanager**: Alert routing and management
   - **Node Exporter**: Host-level metrics
   - **Kube State Metrics**: Kubernetes object metrics
   - **Operator**: Manages ServiceMonitors and PrometheusRules

2. **Elasticsearch** (EFK Stack):
   - Version: 8.5.1
   - Replicas: 1 (single-node cluster for dev)
   - Storage: 10Gi persistent volume
   - Purpose: Log storage and indexing

3. **Fluent Bit**:
   - DaemonSet on all nodes
   - Collects logs from all containers
   - Forwards to Elasticsearch
   - Kubernetes metadata enrichment

4. **Kibana**:
   - Version: 8.5.1
   - Connected to Elasticsearch
   - Log visualization and exploration

**Resource Allocation**:
```yaml
Prometheus:
  requests: 200m CPU, 512Mi memory
  limits: 500m CPU, 1Gi memory

Elasticsearch:
  requests: 500m CPU, 2Gi memory
  limits: 1000m CPU, 3Gi memory

Fluent Bit:
  requests: 100m CPU, 128Mi memory
  limits: 200m CPU, 256Mi memory
```

**Access Methods**:
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Grafana (default credentials: admin/prom-operator)
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601
```

**Outputs**:
- `prometheus_url`: Port-forward URL for Prometheus
- `grafana_url`: Port-forward URL for Grafana
- `kibana_url`: Port-forward URL for Kibana
---
## ⚙️ Configuration

### Environment Variables (`env/dev.tfvars`)

This file contains all environment-specific values, example:

```hcl
# Project Identification
project = "portfolio"
env     = "dev"
region  = "ap-south-1"

# Network Configuration
vpc_cidr   = "10.0.0.0/16"      # VPC IP range
az_count   = 2                   # Number of availability zones
enable_nat = true                # Enable NAT for private subnet egress

# EKS Node Group Configuration
instance_types = ["t3a.medium"]  # EC2 instance type
min_size       = 2               # Minimum nodes
desired_size   = 3               # Initial node count
max_size       = 3               # Maximum nodes
capacity_type  = "ON_DEMAND"     # ON_DEMAND or SPOT

# Container Registry
ecr_repository_name = "flashcards-app"

# GitOps Configuration
gitops_repo_url      = "https://gitlab.com/user/repo.git"
gitops_repo_branch   = "main"
gitops_repo_username = "Lielik"
gitops_repo_password = "glpat-xxx"  # GitLab Personal Access Token
```

### Backend Configuration (`env/dev.backend.hcl`)

Defines where Terraform state is stored, example:

```hcl
bucket       = "tfstate-flashcards"
key          = "dev/terraform.tfstate"
region       = "ap-south-1"
encrypt      = true
use_lockfile = true
```

### Makefile Shortcuts

Simplifies common Terraform commands:

```makefile
# Initialize with backend config
make init

# Plan changes
make plan

# Apply changes
make apply

# Destroy infrastructure
make destroy

# Format code
make fmt

# Validate configuration
make validate
```
---
## 📖 Deployment Guide

### Step-by-Step Deployment

#### Step 1: Pre-Deployment Checks

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Ensure S3 bucket exists
aws s3 ls s3://tfstate-flashcards

# Verify ECR repositories
aws ecr describe-repositories --repository-names flashcards-app flashcards-nginx
```

#### Step 2: Initialize Terraform

```bash
# Initialize providers and backend
terraform init -backend-config=env/dev.backend.hcl

# Expected output:
# Terraform has been successfully initialized!
```

This command:
- Downloads required provider plugins (AWS, Kubernetes, Helm)
- Configures S3 backend for state storage
- Initializes modules

#### Step 3: Plan Infrastructure

```bash
# Generate execution plan
terraform plan -var-file=env/dev.tfvars -out=tfplan

# Review the plan carefully:
# - Resources to be created (+)
# - Resources to be changed (~)
# - Resources to be destroyed (-)
```

**What to look for**:
- Approximately 50-60 resources will be created
- No unexpected deletions
- Resource names match expected naming convention

#### Step 4: Apply Infrastructure

```bash
# Apply the plan
terraform apply -var-file=env/dev.tfvars

# Or use the saved plan:
terraform apply tfplan

# Type 'yes' when prompted
```

**Deployment Timeline**:
- Network resources: ~2 minutes
- EKS cluster: ~10-12 minutes
- Node group: ~3-5 minutes
- Helm releases: ~5-7 minutes
- **Total: ~20-25 minutes**

#### Step 5: Configure kubectl

```bash
# Update kubeconfig
aws eks update-kubeconfig --name portfolio-dev-eks --region ap-south-1

# Verify connection
kubectl get nodes

# Expected output:
# NAME                                           STATUS   ROLES    AGE   VERSION
# ip-10-0-100-xxx.ap-south-1.compute.internal   Ready    <none>   5m    v1.28.x
# ip-10-0-101-xxx.ap-south-1.compute.internal   Ready    <none>   5m    v1.28.x
```

#### Step 6: Verify ArgoCD Installation

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# All pods should be Running:
# argocd-server-xxx
# argocd-repo-server-xxx
# argocd-application-controller-xxx
# argocd-redis-xxx

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo

# Port-forward to ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: <from command above>
```

#### Step 7: Verify Application Deployment

```bash
# Check ArgoCD applications
kubectl get applications -n argocd

# Expected applications:
# cert-manager    Synced   Healthy
# flashcards      Synced   Healthy

# Check application pods
kubectl get pods -n apps

# Expected pods:
# flashcards-app-api-xxx (2 replicas)
# flashcards-app-nginx-xxx (2 replicas)
# flashcards-mongodb-0 (1 replica)
```

#### Step 8: Access Application

```bash
# Get the Load Balancer URL
kubectl get svc -n ingress-nginx ingress-nginx-controller \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Or use the output from Terraform:
terraform output app_url_command

# Access the application:
# http://<load-balancer-dns>
```

### Post-Deployment Verification

```bash
# 1. Check all namespaces
kubectl get ns

# 2. Verify monitoring stack
kubectl get pods -n monitoring
kubectl get pods -n logging

# 3. Check ingress
kubectl get ingress -n apps

# 4. View all services
kubectl get svc --all-namespaces

# 5. Check persistent volumes
kubectl get pv
```
---
## 📊 Monitoring & Logging

### Accessing Monitoring Tools

#### Prometheus

```bash
# Port-forward Prometheus
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Access: http://localhost:9090
```

**Useful Queries**:
```promql
# API request rate
rate(flashcard_api_requests_total[5m])

# P95 response time
histogram_quantile(0.95, rate(flashcard_api_request_duration_seconds_bucket[5m]))

# Error rate
rate(flashcard_api_requests_total{status=~"5.."}[5m])

# Pod CPU usage
sum(rate(container_cpu_usage_seconds_total{namespace="apps"}[5m])) by (pod)
```

#### Grafana

```bash
# Port-forward Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

# Access: http://localhost:3000
# Username: admin
# Password: prom-operator
```

**Pre-configured Dashboards**:
- Kubernetes / Compute Resources / Cluster
- Kubernetes / Compute Resources / Namespace (Pods)
- Node Exporter / Nodes

**Import Custom Dashboard**:
1. Navigate to Dashboards > Import
2. Upload `dashboards/monitoring/Infrastructure & Performance.json`
3. View application-specific metrics

#### Kibana

```bash
# Port-forward Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601

# Access: http://localhost:5601
```

**Setup Index Pattern**:
1. Go to Management > Stack Management > Index Patterns
2. Create index pattern: `fluentbit-*`
3. Select timestamp field: `@timestamp`
4. View logs in Discover tab

**Useful Kibana Queries**:
```
# Application logs
kubernetes.namespace_name: "apps"

# Error logs
log: *error* OR log: *ERROR*

# API requests
kubernetes.pod_name: flashcards-app-api*

# MongoDB logs
kubernetes.pod_name: flashcards-mongodb*
```
---
### Custom Dashboards

The repository includes a custom Grafana dashboard at:
`dashboards/monitoring/Infrastructure & Performance.json`

**Metrics Displayed**:
- API request rate and error rate
- Response time percentiles
- Database connections
- Pod resource usage
- Node resource usage
- Persistent volume usage
---
## 💰 Cost Management

### Estimated Monthly Costs

**Development Environment (8 hours/day, 22 days/month)**:

| Service | Configuration | Monthly Cost |
|---------|---------------|--------------|
| EKS Control Plane | 1 cluster | ~$73 |
| EC2 Instances | 3 x t3a.medium (8h/day) | ~$35 |
| NAT Gateway | 1 NAT (8h/day) | ~$22 |
| EBS Volumes | ~30Gi total | ~$3 |
| Network Transfer | Minimal | ~$5 |
| **Total** | | **~$138/month** |

**If running 24/7**: ~$300-350/month

### Cost Optimization Strategies

#### 1. Daily Start/Stop Workflow

```bash
# Morning: Start infrastructure
terraform apply -var-file=env/dev.tfvars -auto-approve

# Evening: Destroy infrastructure
terraform destroy -var-file=env/dev.tfvars -auto-approve
```

**Savings**: ~60-70% of costs

#### 2. Use SPOT Instances

Modify `env/dev.tfvars`:
```hcl
capacity_type = "SPOT"
```

**Savings**: ~70% on EC2 costs  
**Trade-off**: Nodes can be terminated with 2-minute notice

#### 3. Scale Down When Not in Use

```bash
# Scale node group to 0
aws eks update-nodegroup-config \
  --cluster-name portfolio-dev-eks \
  --nodegroup-name portfolio-dev-ng \
  --scaling-config minSize=0,maxSize=3,desiredSize=0

# Scale back up
aws eks update-nodegroup-config \
  --cluster-name portfolio-dev-eks \
  --nodegroup-name portfolio-dev-ng \
  --scaling-config minSize=2,maxSize=3,desiredSize=2
```

#### 4. Monitor Costs

```bash
# Check current month's costs
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://cost-filter.json

# cost-filter.json:
{
  "Tags": {
    "Key": "Project",
    "Values": ["portfolio"]
  }
}
```

### Resource Tagging

All resources are tagged for cost tracking:

```hcl
tags = {
  Project     = "portfolio"
  Environment = "dev"
  ManagedBy   = "terraform"
}
```

Use AWS Cost Explorer to filter by these tags.
---
### Debugging Commands

```bash
# Check Terraform state
terraform show
terraform state list

# Validate configuration
terraform validate
terraform fmt -check -recursive

# Detailed apply output
TF_LOG=DEBUG terraform apply -var-file=env/dev.tfvars

# Refresh state
terraform refresh -var-file=env/dev.tfvars

# Import existing resource
terraform import module.eks.aws_eks_cluster.cluster portfolio-dev-eks

# Remove resource from state (without destroying)
terraform state rm module.monitoring.helm_release.prometheus
```
---
## 🧹 Cleanup

### Complete Infrastructure Teardown

```bash
# 1. Delete Kubernetes resources that create AWS resources
kubectl delete svc --all -n ingress-nginx
kubectl delete ingress --all --all-namespaces
kubectl delete pvc --all --all-namespaces

# 2. Wait 2-3 minutes for AWS resources to be cleaned up

# 3. Destroy Terraform-managed infrastructure
terraform destroy -var-file=env/dev.tfvars

# 4. Confirm destruction
# Type: yes

# 5. Verify all resources deleted
aws eks list-clusters
aws ec2 describe-vpcs --filters "Name=tag:Project,Values=portfolio"
```
### Emergency Cleanup

If Terraform destroy fails repeatedly:

```bash
# 1. Manually delete in AWS Console:
# - Load Balancers (EC2 > Load Balancers)
# - Target Groups
# - Security Groups (except default)
# - NAT Gateway
# - Elastic IPs
# - EKS Node Group
# - EKS Cluster
# - VPC (will cascade delete subnets, route tables, IGW)

# 2. Clean Terraform state
rm -rf .terraform terraform.tfstate* tfplan

# 3. Re-initialize if needed
terraform init -backend-config=env/dev.backend.hcl
```

## 📚 Additional Resources

### Documentation
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Operator](https://prometheus-operator.dev/)

### Terraform Best Practices
- Use modules for reusability
- Version lock providers
- Remote state with locking
- Meaningful resource naming
- Comprehensive outputs
- Environment separation

### Security Best Practices
- Private subnets for worker nodes
- IAM roles with least privilege
- Encrypted secrets (Sealed Secrets)
- Network policies for pod communication
- Regular security updates
- Audit logging enabled
---

**Project**: Flashcards Infrastructure  
**Cloud Provider**: AWS  
**Region**: ap-south-1 (Mumbai)  
**Terraform Version**: >= 1.5.0  
**Kubernetes Version**: Latest EKS (1.28+)  
**Estimated Monthly Cost**: $138 (8h/day) | $300-350 (24/7)