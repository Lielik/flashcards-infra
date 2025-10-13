
resource "helm_release" "argocd" {
  name = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart = "argo-cd"
  version = "7.0.0"
  namespace = var.namespace
  create_namespace = true
  wait = true
  timeout = 600

  values = [
    yamlencode({
      global = {
        # Domain where ArgoCD will be accessible (optional, can be configured later)
        domain = var.argocd_domain
      }

      # Configuration for the ArgoCD server (the UI and API)
      server = {
        extraArgs = [
          # --insecure disables TLS/HTTPS
          # This is OK for internal use or when using an external load balancer for TLS
          # In production, you might want to remove this and configure proper certificates
          "--insecure"
        ]

        # Service configuration for the ArgoCD server
        service = {
          # Creates an AWS Load Balancer to expose ArgoCD gives a public URL to access the ArgoCD UI
          type = "LoadBalancer"

          # Annotations are key-value pairs that modify how the LoadBalancer behaves
          annotations = {
            # This tells AWS to create a Network Load Balancer (NLB) instead of Classic LB
            # NLBs are more modern, faster, and support more features
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"

            # This makes the NLB accessible from the internet
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }

        # Ingress configuration (disabled because we're using LoadBalancer)
        ingress = {
          enabled = false
        }
      }

      redis = {
        enabled = true
      }

      # Configuration for Dex (authentication/SSO server)
      dex = {
        # Enabled if you want to use external authentication (Google, GitHub, etc.)
        # Disabled means you'll only use the default admin user
        enabled = false
      }

      # Configurations section - creates a ConfigMap with settings
      configs = {
        # Repository credentials and configuration
        repositories = {
          # This is a placeholder - actual repo will be added via application
          # You can hardcode repository credentials here if needed
        }
      }
    })
  ]

  # depends_on ensures this resource waits for the cluster to be ready
  # Without this, Terraform might try to install ArgoCD before EKS is fully operational
  depends_on = [var.cluster_endpoint]
}

# -----------------------------
# Create ArgoCD Application for GitOps Repo
# -----------------------------
# This creates an ArgoCD "Application" resource that tells ArgoCD
# where your GitOps repository is and how to sync it
resource "kubectl_manifest" "gitops_application" {
  # Only create this if gitops_repo_url is provided
  count = var.gitops_repo_url != "" ? 1 : 0

  # The YAML definition of the ArgoCD Application
  yaml_body = yamlencode({
    # API version for ArgoCD Application resource
    apiVersion = "argoproj.io/v1alpha1"
    kind = "Application"
    metadata = {
      name = var.gitops_app_name
      namespace = var.namespace
      
      # Finalizers ensure proper cleanup when you delete the application - makes sure ArgoCD cleans up all resources it created
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    
    spec = {
      # The project this application belongs to
      # "default" is the built-in project that all users have access to
      project = "default"
      
      # source defines WHERE to get the application manifests
      source = {
        repoURL = var.gitops_repo_url
        targetRevision = var.gitops_repo_branch
        # Path within the repository where manifests are located
        path = var.gitops_repo_path
      }

      destination = {
        # Server URL of the Kubernetes cluster
        # https://kubernetes.default.svc means "this cluster" (the one ArgoCD is running in)
        server = "https://kubernetes.default.svc"
        
        # Kubernetes namespace where applications will be deployed
        # If empty, uses the namespace specified in the manifests
        namespace = var.gitops_target_namespace
      }
      
      # syncPolicy defines HOW ArgoCD should sync the applications
      syncPolicy = {
        # automated means ArgoCD will automatically sync without manual intervention
        automated = {
          prune = true
          selfHeal = true
          allowEmpty = false
        }
        
        syncOptions = [
          "CreateNamespace=true"
        ]
        
        # retry policy for failed syncs
        retry = {
          limit = 5
          backoff = {
            duration = "5s"
            factor = 2
            maxDuration = "3m"
          }
        }
      }
    }
  })

  # depends_on ensures ArgoCD is installed before we try to create applications
  depends_on = [helm_release.argocd]
}

# -----------------------------
# Data Source: Get LoadBalancer URL
# -----------------------------
# This waits for the LoadBalancer to be created and retrieves its URL
# You'll use this URL to access the ArgoCD UI
data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = var.namespace
  }

  # Wait for the helm release to complete before trying to read the service
  depends_on = [helm_release.argocd]
}
