# -----------------------------
# Cluster Outputs
# -----------------------------
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.cluster.name
}

output "cluster_endpoint" {
  description = "Cluster API server endpoint"
  value       = data.aws_eks_cluster.cluster_info.endpoint
}

output "cluster_ca" {
  description = "Base64-encoded CA data for the cluster"
  value       = data.aws_eks_cluster.cluster_info.certificate_authority[0].data
}

# -----------------------------
# Node Group Output
# -----------------------------
output "node_group_name" {
  description = "Name of the managed node group"
  value       = aws_eks_node_group.workers.node_group_name
}

# -----------------------------
# OIDC Provider Output
# -----------------------------
output "oidc_provider_arn" {
  description = "ARN of the IAM OIDC provider"
  value       = aws_iam_openid_connect_provider.oidc_provider.arn
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.oidc_provider.url
}
