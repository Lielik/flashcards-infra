# ==========================================================
# provider.tf
# ----------------------------------------------------------
# - Locks versions (Terraform + providers) and defines the backend.
# - Configures AWS, Kubernetes, Helm, and kubectl providers.
# - Effect: Terraform can manage AWS infrastructure and Kubernetes resources.
# ==========================================================


terraform {
  backend "s3" {
  }

  required_providers {
    # AWS provider for infrastructure provisioning
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }

    # Kubernetes provider for interacting with the EKS cluster
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    # Helm provider for installing Helm charts (like ArgoCD)
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

    # kubectl provider for advanced Kubernetes resource management
    # This is needed for ArgoCD Application custom resources
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}


provider "aws" {
  region = var.region
}

# -----------------------------
# Kubernetes Provider
# -----------------------------
# This provider lets Terraform interact with your EKS cluster's Kubernetes API
# It authenticates using AWS credentials and the EKS cluster information
provider "kubernetes" {
  # The API server endpoint of your EKS cluster
  host = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command = "aws"

    # Arguments passed to the command
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.region
    ]
  }
}

# -----------------------------
# Helm Provider
# -----------------------------
# This provider lets Terraform install and manage Helm charts
# Configuration is identical to the Kubernetes provider
provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        var.region
      ]
    }
  }
}

# -----------------------------
# kubectl Provider
# -----------------------------
# This provider handles Kubernetes custom resources better than the standard kubernetes provider
# Used specifically for creating ArgoCD Application resources
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      var.region
    ]
  }
}