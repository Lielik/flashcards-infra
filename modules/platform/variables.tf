# ==========================================================
# modules/platform/variables.tf
# ----------------------------------------------------------
# Inputs for the platform module (IAM + EKS).
# Provisions EKS cluster, OIDC, node group, and required IAM roles.
# ==========================================================

variable "name" {
  description = "Base name/prefix for cluster resources (e.g., flashcards-dev)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the cluster and node group"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for the node group (e.g., [\"t3a.medium\"])"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired capacity of the managed node group"
  type        = number
}

variable "min_size" {
  description = "Minimum capacity of the managed node group"
  type        = number
}

variable "max_size" {
  description = "Maximum capacity of the managed node group"
  type        = number
}

variable "capacity_type" {
  description = "Capacity type for nodes: ON_DEMAND or SPOT"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to EKS and IAM resources"
  type        = map(string)
}
