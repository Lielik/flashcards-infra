# -----------------------------
# Local Naming & Tagging
# -----------------------------

locals {
  name_prefix = "${var.project}-${var.env}"

  tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  }
}


# -----------------------------
# Network Module
# -----------------------------
# Creates the VPC, public/private subnets, Internet Gateway,
# NAT Gateway (optional), and route tables.
# Provides subnet IDs for use by the platform module.
# -----------------------------

module "network" {
  source     = "./modules/network"
  name       = local.name_prefix
  vpc_cidr   = var.vpc_cidr
  az_count   = 2
  enable_nat = true
  tags       = local.tags
}


# --- IAM ---
module "iam" {
  source = "./modules/iam"
  name   = local.name_prefix
  tags   = local.tags
}

# --- EKS ---
module "eks" {
  source             = "./modules/eks"
  name               = local.name_prefix
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
  capacity_type      = var.capacity_type
  tags               = local.tags
}

# -----------------------------
# Existing ECR (data source only)
# -----------------------------
data "aws_ecr_repository" "existing" {
  name = var.ecr_repository_name
}

# -----------------------------
# ArgoCD Module
# -----------------------------
# Installs ArgoCD via Helm and configures it to sync with your GitOps repository
# This enables continuous deployment from Git to your EKS cluster
# -----------------------------

module "argocd" {
  source = "./modules/argocd"

  # Basic configuration
  name      = local.name_prefix
  tags      = local.tags
  namespace = "argocd"

  # EKS cluster connection information
  # These values come from the eks module
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  cluster_name     = module.eks.cluster_name
  aws_region       = var.region

  # GitOps repository configuration
  # IMPORTANT: Update these variables to point to your actual GitOps repository
  gitops_repo_url    = var.gitops_repo_url
  gitops_repo_branch = var.gitops_repo_branch
  gitops_repo_path   = var.gitops_repo_path

  # Application configuration
  gitops_app_name         = "${local.name_prefix}-app"
  gitops_target_namespace = var.gitops_target_namespace

  # Optional: Custom domain for ArgoCD
  # Leave empty if you'll use the LoadBalancer URL
  argocd_domain = ""

  # Ensure ArgoCD is installed only after the cluster is ready
  # This prevents errors during infrastructure provisioning
  depends_on = [module.eks]
}
