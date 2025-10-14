
output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = local.argocd_namespace
}

output "argocd_initial_admin_password_command" {
  description = "Command to get ArgoCD admin password"
  value       = "kubectl -n ${local.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
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
