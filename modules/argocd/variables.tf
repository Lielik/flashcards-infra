# ==========================================================
# modules/argocd/variables.tf
# ----------------------------------------------------------
# Input variables for the ArgoCD module
# ==========================================================

# -----------------------------
# Basic Configuration
# -----------------------------

variable "name" {
  description = "Base name prefix for ArgoCD resources"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all ArgoCD resources"
  type        = map(string)
}

variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

# Domain name for ArgoCD (optional)
# If you have a custom domain like "argocd.yourcompany.com", specify it here
# Leave empty if you'll just use the LoadBalancer URL
variable "argocd_domain" {
  description = "Domain for ArgoCD (optional)"
  type        = string
  default     = ""
}

# -----------------------------
# EKS Cluster Connection
# -----------------------------

# The EKS cluster endpoint (API server URL)
# This tells ArgoCD module which cluster to connect to
variable "cluster_endpoint" {
  description = "EKS cluster endpoint (used as dependency)"
  type        = string
}

# The base64-encoded certificate authority data for the cluster
# This is needed to securely communicate with the Kubernetes API
variable "cluster_ca" {
  description = "EKS cluster certificate authority data"
  type        = string
}

# The name of your EKS cluster
# This is used by the AWS CLI to get authentication tokens
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# The AWS region where your cluster is located
# Needed for authentication and AWS API calls
variable "aws_region" {
  description = "AWS region where the cluster is located"
  type        = string
}

# -----------------------------
# GitOps Repository Configuration
# -----------------------------

# URL of your GitOps repository
variable "gitops_repo_url" {
  description = "URL of the GitOps repository for ArgoCD to sync"
  type        = string
}

# Git branch that ArgoCD should track
# ArgoCD will watch this branch for changes and auto-deploy them
variable "gitops_repo_branch" {
  description = "Git branch for ArgoCD to track"
  type        = string
}

# Path within the repository where Kubernetes manifests are located
# Example: "kubernetes/apps" or "helm-charts" or "manifests"
# Leave as "." to use the repository root
variable "gitops_repo_path" {
  description = "Path within the repository where manifests are located"
  type        = string
}

# Name for the ArgoCD Application resource
# This is just a friendly name shown in the ArgoCD UI
variable "gitops_app_name" {
  description = "Name for the ArgoCD Application"
  type        = string
}

# Target namespace where your application will be deployed
# Leave empty to use whatever namespace is specified in your manifests
variable "gitops_target_namespace" {
  description = "Kubernetes namespace where the app will be deployed"
  type        = string
}
