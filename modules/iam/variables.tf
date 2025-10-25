# ==========================================================
# Input variables for the IAM module
# ==========================================================

variable "name" {
  description = "Base name prefix for IAM roles (e.g., flashcards-dev)"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to IAM resources"
  type        = map(string)
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the EKS OIDC provider for IRSA"
  type        = string
}
