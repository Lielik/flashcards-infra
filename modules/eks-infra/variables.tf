variable "name" {
  description = "Base name prefix"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "cluster_endpoint" {
  description = "EKS cluster endpoint (dependency)"
  type        = string
}

variable "cluster_ca" {
  description = "EKS cluster CA"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "gitops_repo_url" {
  description = "URL of GitOps repository"
  type        = string
}

variable "gitops_repo_branch" {
  description = "Git branch to track"
  type        = string
  default     = "main"
}

variable "gitops_repo_username" {
  type        = string
  description = "Username for HTTPS auth (use 'oauth2' for GitLab PAT)."
  default     = "oauth2"
}

variable "gitops_repo_password" {
  type        = string
  description = "GitLab Personal Access Token (scope: read_repository)."
  sensitive   = true
}
