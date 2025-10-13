# ==========================================================
# modules/argocd/outputs.tf
# ----------------------------------------------------------
# Outputs from the ArgoCD module
# These values will be available after terraform apply
# ==========================================================

# -----------------------------
# ArgoCD Access Information
# -----------------------------

# The URL where you can access the ArgoCD web UI
# This will be the LoadBalancer DNS name created by AWS
output "argocd_url" {
  description = "URL to access ArgoCD UI (LoadBalancer)"
  # Get the hostname from the LoadBalancer ingress
  value = length(data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress) > 0 ? (
    # If the LoadBalancer has a hostname (AWS ELB), use that
    data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname != "" ?
    "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].hostname}" :
    # Otherwise, use the IP address
    "http://${data.kubernetes_service.argocd_server.status[0].load_balancer[0].ingress[0].ip}"
  ) : "LoadBalancer URL pending..."
}

output "argocd_namespace" {
  description = "Kubernetes namespace where ArgoCD is installed"
  value       = var.namespace
}

# -----------------------------
# Initial Admin Password Command
# -----------------------------

# Command to retrieve the initial admin password for ArgoCD
output "argocd_initial_admin_password_command" {
  description = "Command to retrieve the initial ArgoCD admin password"
  value       = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

# -----------------------------
# ArgoCD Server Service Name
# -----------------------------

output "argocd_server_service_name" {
  description = "Name of the ArgoCD server service"
  value       = data.kubernetes_service.argocd_server.metadata[0].name
}

# -----------------------------
# GitOps Configuration (if configured)
# -----------------------------

# The URL of the GitOps repository being synced
# Empty if no GitOps repo was configured
output "gitops_repo_url" {
  description = "GitOps repository URL (if configured)"
  value       = var.gitops_repo_url != "" ? var.gitops_repo_url : "Not configured"
}

# The branch being tracked by ArgoCD
output "gitops_repo_branch" {
  description = "GitOps repository branch being tracked"
  value       = var.gitops_repo_url != "" ? var.gitops_repo_branch : "Not configured"
}

# The name of the Application resource created in ArgoCD
output "gitops_application_name" {
  description = "Name of the ArgoCD Application (if configured)"
  value       = var.gitops_repo_url != "" ? var.gitops_app_name : "Not configured"
}
