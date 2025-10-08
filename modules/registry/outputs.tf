# ==========================================================
# modules/registry/outputs.tf
# ----------------------------------------------------------
# Exposes repository URL and ARN for CI/CD usage.
# ==========================================================

output "repository_url" {
  description = "URL of the ECR repository (e.g., 123.dkr.ecr.region.amazonaws.com/repo)"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.this.arn
}
