# ==========================================================
# modules/argocd/main.tf
# ----------------------------------------------------------
# Installs ArgoCD via Helm and creates bootstrap Application
# ==========================================================

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# Install ArgoCD Helm chart
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.0.0"
  namespace        = var.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        extraArgs = ["--insecure"]
      }
      redis = {
        enabled = true
      }
    })
  ]

  depends_on = [var.cluster_endpoint]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argocd" {
  depends_on      = [helm_release.argocd]
  create_duration = "30s"
}

# Get the LoadBalancer URL
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }

  depends_on = [helm_release.argocd]
}

# Bootstrap Application using kubectl (more reliable than kubernetes_manifest)
resource "null_resource" "bootstrap_app" {
  # Recreate if manifest content changes
  triggers = {
    manifest_sha = sha256(jsonencode({
      repo   = var.gitops_repo_url
      branch = var.gitops_repo_branch
      path   = "charts/argocd"
    }))
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Update kubeconfig
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}
      
      # Apply the bootstrap Application
      cat <<EOF | kubectl apply -f -
      apiVersion: argoproj.io/v1alpha1
      kind: Application
      metadata:
        name: bootstrap
        namespace: ${var.namespace}
        annotations:
          argocd.argoproj.io/sync-wave: "-1"
      spec:
        project: default
        source:
          repoURL: ${var.gitops_repo_url}
          targetRevision: ${var.gitops_repo_branch}
          path: charts/argocd
        destination:
          server: https://kubernetes.default.svc
          namespace: ${var.namespace}
        syncPolicy:
          automated:
            prune: true
            selfHeal: true
          syncOptions:
          - CreateNamespace=true
          retry:
            limit: 5
            backoff:
              duration: 5s
              factor: 2
              maxDuration: 3m
      EOF
    EOT
  }

  depends_on = [
    time_sleep.wait_for_argocd,
    helm_release.argocd
  ]
}