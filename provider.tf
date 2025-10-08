# ==========================================================
# provider.tf
# ----------------------------------------------------------
# - Locks versions (Terraform + AWS provider) and defines the backend (local state for now).
# - Configures the AWS provider with the region you pass in via variables.
# - Effect: Terraform knows how to talk to AWS and where to keep state.
# ==========================================================


# -----------------------------
# Terraform & Provider Versions
# -----------------------------
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  # -----------------------------
  # Backend Configuration
  # -----------------------------
  # For now, use a local backend that writes to terraform.tfstate.
  # In production, migrate this to S3 + DynamoDB for locking.
  # -----------------------------
  backend "local" {
    path = "terraform.tfstate"
  }
}


# -----------------------------
# AWS Provider
# -----------------------------
provider "aws" {
  region = var.region
}
