# ==========================================================
# outputs.tf
# ----------------------------------------------------------
# Responsibilities:
#   - Expose key identifiers and connection details from all modules
#   - Provide ready-to-run convenience commands for interacting
#     with the EKS cluster and verifying the deployment
#
# ==========================================================


# ==========================================================
# outputs.tf
# ----------------------------------------------------------
# Root-level outputs: networking, EKS, IAM, ECR, commands
# ==========================================================

# -----------------------------
# 1. Networking Outputs
# -----------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.network.private_subnet_ids
}


# -----------------------------
# 2. EKS / Cluster Outputs
# -----------------------------

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = module.eks.node_group_name
}


# -----------------------------
# 3. IAM Role Outputs
# -----------------------------

output "cluster_role_arn" {
  description = "ARN of IAM role used by the EKS control plane"
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "ARN of IAM role used by the EKS worker nodes"
  value       = module.iam.node_role_arn
}


# -----------------------------
# 4. ECR / Repository Outputs
# -----------------------------

output "ecr_repository_url" {
  description = "URL of the existing ECR repository"
  value       = data.aws_ecr_repository.existing.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the existing ECR repository"
  value       = data.aws_ecr_repository.existing.arn
}

# -----------------------------
# 5. ArgoCD Outputs
# -----------------------------

output "gitops_repo_url" {
  description = "GitOps repository URL being synced by ArgoCD"
  value       = var.gitops_repo_url
}

output "gitops_repo_branch" {
  description = "Git branch being tracked by ArgoCD"
  value       = var.gitops_repo_branch
}

output "argocd_admin_password_command" {
  description = "Command to retrieve the ArgoCD admin password from the Kubernetes secret"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo"
}

# -----------------------------
# 6. Convenience Commands
# -----------------------------

output "kubectl_config_command" {
  description = "Command to configure kubectl for your EKS cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "kubectl_get_nodes_command" {
  description = "Command to check cluster node status"
  value       = "kubectl get nodes -o wide"
}

# -----------------------------
# Summary Output
# -----------------------------

output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project     = var.project
    environment = var.env
    region      = var.region
    cluster     = module.eks.cluster_name
    gitops_repo = var.gitops_repo_url
  }
}
