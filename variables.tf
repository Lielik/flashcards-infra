# ==========================================================
# variables.tf
# ----------------------------------------------------------
# - Declares all required inputs (no defaults): project/env/region, VPC CIDR, and EKS node group settings.
# - These are referenced by main.tf and passed down to modules.
# - Effect: Forces you to drive configuration from env/*.tfvars so everything is explicit and environment-specific.
# ==========================================================


# -----------------------------
# 1. Project & Environment Metadata
# -----------------------------

variable "project" {
  description = "Project name (used for naming & tagging)"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region for resource creation"
  type        = string
}


# --------------
# 2. Networking 
# --------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR, e.g. 10.0.0.0/16"
  }
}

variable "az_count" {
  description = "Number of availability zones to span"
  type        = number
  default     = 2
}
variable "enable_nat" {
  description = "Whether to create NAT gateway for private subnets"
  type        = bool
  default     = false
}


# -----------------------------
# 3. EKS Node Group Configuration
# -----------------------------

variable "instance_types" {
  description = "List of EC2 instance types for your EKS nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes for auto-scaling"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes for auto-scaling"
  type        = number
}

variable "capacity_type" {
  description = "Capacity type for your node group (ON_DEMAND or SPOT)"
  type        = string
}

# -----------------------------
# 4. ECR Repository (existing)
# -----------------------------

variable "ecr_repository_name" {
  description = "Name of an existing ECR repository to use"
  type        = string
}

# -----------------------------
# 5. GitOps Repository Configuration
# -----------------------------

variable "gitops_repo_url" {
  description = "URL of your GitOps repository where Kubernetes manifests are stored"
  type        = string
}

variable "gitops_repo_branch" {
  description = "Git branch that ArgoCD should track for changes."
  type        = string
}

variable "gitops_repo_path" {
  description = "Path within the GitOps repository where Kubernetes manifests are located"
  type        = string
}

variable "gitops_target_namespace" {
  description = "Kubernetes namespace where your application will be deployed"
  type        = string
}
