# ==========================================================
# modules/registry/variables.tf
# ----------------------------------------------------------
# Inputs for the registry (ECR) module.
# ==========================================================

variable "name" {
  description = "Base name/prefix used for tagging (e.g., flashcards-dev)"
  type        = string
}

variable "repository" {
  description = "Name of the ECR repository to create"
  type        = string
}

variable "force_delete" {
  description = "If true, allows deleting a repository even if it contains images"
  type        = bool
}

variable "tags" {
  description = "Common tags to apply to the ECR repository"
  type        = map(string)
}
