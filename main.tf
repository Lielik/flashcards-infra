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
  source            = "./modules/iam"
  name              = local.name_prefix
  tags              = local.tags
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
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
# infra related services for eks
# -----------------------------
module "eks-infra" {
  source = "./modules/eks-infra"

  name = local.name_prefix
  tags = local.tags


  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca       = module.eks.cluster_ca
  cluster_name     = module.eks.cluster_name
  aws_region       = var.region

  # Just point to the GitOps repo!
  gitops_repo_url      = var.gitops_repo_url
  gitops_repo_branch   = var.gitops_repo_branch
  gitops_repo_username = var.gitops_repo_username
  gitops_repo_password = var.gitops_repo_password

  vpc_id = module.network.vpc_id

  depends_on = [module.eks]

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }
}

# -----------------------------
# Monitoring and Logging Module
# -----------------------------
module "monitoring" {
  source = "./modules/monitoring"

  enable_logging    = true
  enable_monitoring = true

  depends_on = [module.eks] # Wait for EKS cluster to be ready
}
