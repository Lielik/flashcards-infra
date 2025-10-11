# ==========================================================
# modules/iam/variables.tf
# ----------------------------------------------------------
# Input variables for the IAM module
# ==========================================================

# -----------------------------
# Naming & Tags
# -----------------------------

variable "name" {
  description = "Base name prefix for IAM roles (e.g., flashcards-dev)"
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to IAM resources"
  type        = map(string)
}
