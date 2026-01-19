# ==========================================================
#   - Expose key identifiers and connection details from all modules
#   - Provide ready-to-run convenience commands for interacting
#     with the EKS cluster and verifying the deployment
# ==========================================================

# -----------------------------
# Networking Outputs
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
# EKS / Cluster Outputs
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
# IAM Role Outputs
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
# ECR / Repository Outputs
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
# ArgoCD Outputs
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
# Static Files S3 Bucket Outputs
# -----------------------------
output "static_files_bucket_name" {
  description = "Name of the S3 bucket for static files"
  value       = data.aws_s3_bucket.static_files.id
}

output "static_files_bucket_endpoint" {
  description = "S3 bucket regional domain name"
  value       = data.aws_s3_bucket.static_files.bucket_regional_domain_name
}

output "static_files_website_url" {
  description = "S3 website endpoint URL"
  value       = "http://${data.aws_s3_bucket.static_files.bucket_regional_domain_name}"
}

output "upload_static_files_command" {
  description = "Command to upload static files to S3"
  value       = "aws s3 sync ./static/ s3://${data.aws_s3_bucket.static_files.id}/ --delete --region ${var.region}"
}

# -----------------------------
# Convenience Commands
# -----------------------------
output "kubectl_config_command" {
  description = "Command to configure kubectl for your EKS cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

output "kubectl_get_nodes_command" {
  description = "Command to check cluster node status"
  value       = "kubectl get nodes -o wide"
}

output "app_url_command" {
  description = "Command to retrieve the application's external URL. Replace <namespace> and <service-name> with your values."
  value       = "kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | xargs -I{} echo http://{}"
}

