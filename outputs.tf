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

output "eks_cluster_ca" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = module.eks.cluster_ca
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

output "argocd_url" {
  description = "URL to access the ArgoCD web UI"
  value       = module.argocd.argocd_url
}

output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  value       = module.argocd.argocd_namespace
}

output "argocd_admin_password_command" {
  description = "Command to retrieve the initial ArgoCD admin password"
  value       = module.argocd.argocd_initial_admin_password_command
}

output "gitops_repo_url" {
  description = "GitOps repository URL being synced by ArgoCD"
  value       = module.argocd.gitops_repo_url
}

output "gitops_repo_branch" {
  description = "Git branch being tracked by ArgoCD"
  value       = module.argocd.gitops_repo_branch
}

output "gitops_application_name" {
  description = "Name of the ArgoCD Application"
  value       = module.argocd.gitops_application_name
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

output "kubectl_get_argocd_pods_command" {
  description = "Command to check ArgoCD pods"
  value       = "kubectl get pods -n ${module.argocd.argocd_namespace}"
}

output "argocd_applications_command" {
  description = "Command to list ArgoCD applications"
  value       = "kubectl get applications -n ${module.argocd.argocd_namespace}"
}