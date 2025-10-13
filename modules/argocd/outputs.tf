output "argocd_url" {
  description = "URL to access ArgoCD UI"
  value = length(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress) > 0 ? (
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname != "" ?
    "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}" :
    "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip}"
  ) : "LoadBalancer URL pending..."
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = var.namespace
}

output "argocd_initial_admin_password_command" {
  description = "Command to get ArgoCD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
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