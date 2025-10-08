# ==========================================================
# main.tf
# ----------------------------------------------------------
# The orchestrator. It:
#   1. Defines locals for consistent naming and tags.
#   2. Calls three modules in order of dependency:
#       - network → builds the VPC/subnets/etc.
#       - platform → builds IAM roles + EKS cluster + node group (needs subnets from network)
#       - registry → builds the ECR repo
# Effect: Wires inputs into modules, wires module outputs into other modules, producing a dependency graph Terraform can plan/apply safely.
# ==========================================================


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
# 1. Network Module
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


# -----------------------------
# 2. Platform Module (IAM + EKS)
# -----------------------------
# Provisions IAM roles and policies, the EKS cluster,
# OIDC provider, and a managed node group (EC2 workers).
# Requires the VPC and subnet IDs from the network module.
# -----------------------------

module "platform" {
  source             = "./modules/platform"

  name               = local.name_prefix
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
  capacity_type      = var.capacity_type

  tags               = local.tags
}


# -----------------------------
# 3. Registry Module (ECR)
# -----------------------------
# Creates a private Elastic Container Registry repository
# to store Docker images for the Flashcards application.
# -----------------------------

module "registry" {
  source       = "./modules/registry"

  name         = local.name_prefix
  repository   = "${local.name_prefix}-api"
  force_delete = false
  tags         = local.tags
}
