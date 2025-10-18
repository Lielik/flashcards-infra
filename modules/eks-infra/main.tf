# ==========================================================
# modules/argocd/main.tf
# ----------------------------------------------------------
# Installs ArgoCD via Helm and creates bootstrap Application
# ==========================================================


terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

locals {
  argocd_namespace      = "argocd"
  seal_secret_namespace = "kube-system"
}


resource "kubernetes_secret" "sealed_secrets_tls" {
  metadata {
    name      = "sealed-secrets-tls"
    namespace = local.seal_secret_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = file("${path.module}/certs/tls.crt")
    "tls.key" = file("${path.module}/certs/tls.key")
  }

  depends_on = [var.cluster_endpoint]
}

# Install ArgoCD Helm chart
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "8.6.1"
  namespace        = local.argocd_namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  set = [{
    name  = "crds.install"
    value = "true"
  }]

  depends_on = [var.cluster_endpoint]
}

resource "helm_release" "sealed_secrets" {
  name             = "sealed-secrets"
  repository       = "https://bitnami-labs.github.io/sealed-secrets"
  chart            = "sealed-secrets"
  version          = "2.5.2"
  namespace        = local.seal_secret_namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  set = [{
    name  = "secretName"
    value = kubernetes_secret.sealed_secrets_tls.metadata[0].name
  }]

  depends_on = [kubernetes_secret.sealed_secrets_tls]
}

# Install NGINX Ingress Controller via Helm
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.13.3"
  namespace        = "ingress-nginx"
  create_namespace = true
  wait             = true
  timeout          = 600


  values = [file("${path.module}/ingress-nginx/values.yaml")]

  depends_on = [var.cluster_endpoint]
}

# Wait for ArgoCD to be ready
resource "time_sleep" "wait_for_argocd" {
  depends_on      = [helm_release.argocd]
  create_duration = "30s"
}

resource "kubernetes_secret" "gitops_repo_secret" {
  metadata {
    name      = "gitlab-flashcards-gitops"
    namespace = local.argocd_namespace
    labels = {
      # This label tells Argo CD it's a repository connection
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  # Keys must be: url, username, password (for HTTPS)
  data = {
    url      = var.gitops_repo_url
    username = var.gitops_repo_username
    password = var.gitops_repo_password
  }

  type = "Opaque"

  # Make sure Argo CD is installed before we create the repo Secret
  depends_on = [
    helm_release.argocd
  ]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = "argocd"
  }
}

# -----------------------------
# Apply ArgoCD ApplicationSets
# -----------------------------

# Apply Apps ApplicationSet
resource "null_resource" "kubectl_apply" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}
      kubectl apply -f ${path.module}/argocd/apps-applicationset.yaml --namespace ${local.argocd_namespace}
    EOT
  }

  depends_on = [helm_release.argocd]
}

# ==========================================================
# AWS Load Balancer Controller (Helm)
# ==========================================================
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.9.2"

  create_namespace = false

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "region"
      value = var.aws_region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]
}

