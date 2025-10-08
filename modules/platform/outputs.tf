# ==========================================================
# modules/platform/outputs.tf
# ----------------------------------------------------------
# Exposes EKS identifiers, connection details, and IAM role ARNs.
# ==========================================================

# --- EKS connection info ---
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API server endpoint of the EKS cluster"
  value       = data.aws_eks_cluster.this.endpoint
}

output "cluster_ca" {
  description = "Base64-encoded certificate authority data for the cluster"
  value       = data.aws_eks_cluster.this.certificate_authority[0].data
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN (for IRSA)"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "node_group_name" {
  description = "Name of the managed node group"
  value       = aws_eks_node_group.default.node_group_name
}

# --- IAM role ARNs (surfaced for convenience) ---
output "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  value       = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  description = "IAM role ARN for EKS worker nodes"
  value       = aws_iam_role.node.arn
}
