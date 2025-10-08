# ==========================================================
# outputs.tf
# ----------------------------------------------------------
# Centralized list of all Terraform outputs.
#
# Responsibilities:
#   - Expose key identifiers and connection details from all modules
#   - Provide ready-to-run convenience commands for interacting
#     with the EKS cluster and verifying the deployment
#
# Sections:
#   1. Networking
#   2. Platform (EKS + IAM)
#   3. Registry (ECR)
#   4. Convenience Commands
# ==========================================================


# -----------------------------
# 1. Networking
# -----------------------------

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}


# -----------------------------
# 2. Platform (EKS + IAM)
# -----------------------------

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.platform.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = module.platform.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "Base64-encoded certificate authority data for the EKS cluster"
  value       = module.platform.cluster_ca
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = module.platform.node_group_name
}

output "cluster_role_arn" {
  description = "IAM role ARN used by the EKS control plane"
  value       = module.platform.cluster_role_arn
}

output "node_role_arn" {
  description = "IAM role ARN used by EKS worker nodes"
  value       = module.platform.node_role_arn
}


# -----------------------------
# 3. Registry (ECR)
# -----------------------------

output "ecr_repository_url" {
  description = "ECR repository URL for the Flashcards application"
  value       = module.registry.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.registry.repository_arn
}


# -----------------------------
# 4. Convenience Commands
# -----------------------------

output "kubectl_update_kubeconfig_cmd" {
  description = <<-EOT
  Run this command to configure kubectl for the new EKS cluster.
  It updates your local kubeconfig file with the cluster context.
  EOT
  value       = "aws eks update-kubeconfig --name ${module.platform.cluster_name} --region ${var.region}"
}

output "kubectl_smoke_test_cmd" {
  description = <<-EOT
  Simple verification command to confirm that your EKS nodes
  are registered and the cluster is reachable.
  EOT
  value       = "kubectl get nodes -o wide"
}

output "eks_describe_cmd" {
  description = <<-EOT
  Command to describe the EKS cluster using AWS CLI for debugging
  or verification purposes.
  EOT
  value       = "aws eks describe-cluster --name ${module.platform.cluster_name} --region ${var.region} --query 'cluster.{name:name,endpoint:endpoint,version:version,status:status,oidc:identity.oidc.issuer}'"
}
