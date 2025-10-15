output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = local.argocd_namespace
}

output "bootstrap_app_name" {
  description = "Name of the bootstrap application"
  value       = "bootstrap"
}

output "gitops_repo_url" {
  description = "GitOps repository URL"
  value       = var.gitops_repo_url
}

output "gitops_repo_branch" {
  description = "Git branch being tracked"
  value       = var.gitops_repo_branch
}

output "gitops_application_name" {
  description = "Name of the ArgoCD Application"
  value       = "bootstrap"
}


