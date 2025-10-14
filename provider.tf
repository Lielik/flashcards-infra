# ==========================================================
# provider.tf
# ----------------------------------------------------------
# - Locks versions (Terraform + providers) and defines the backend.
# - Configures AWS, Kubernetes, Helm, and kubectl providers.
# - Effect: Terraform can manage AWS infrastructure and Kubernetes resources.
# ==========================================================

terraform {
  backend "s3" {
    # Configuration loaded from env/*.backend.hcl
  }

  required_version = ">= 1.5.0"

  required_providers {
    # AWS provider for infrastructure provisioning
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16.0"
    }

    # Kubernetes provider for interacting with the EKS cluster
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }

    # Helm provider for installing Helm charts (ArgoCD)
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }

    # Time provider for wait/sleep resources
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}

# -----------------------------
# AWS Provider
# -----------------------------
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.env
      ManagedBy   = "terraform"
    }
  }
}

# -----------------------------
# Kubernetes Provider
# -----------------------------
# This provider lets Terraform interact with your EKS cluster's Kubernetes API
# It authenticates using AWS credentials and the EKS cluster information
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)

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

# -----------------------------
# Helm Provider
# -----------------------------
# This provider lets Terraform install and manage Helm charts (ArgoCD)
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
# Null Provider
# -----------------------------
# This provider is used for resources that perform actions locally (provisioners, triggers, etc.)
provider "null" {
}
