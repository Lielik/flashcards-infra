# ==========================================================
# provider.tf
# ----------------------------------------------------------
# - Locks versions (Terraform + AWS provider) and defines the backend (local state for now).
# - Configures the AWS provider with the region you pass in via variables.
# - Effect: Terraform knows how to talk to AWS and where to keep state.
# ==========================================================


terraform {
  backend "s3" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }
}

provider "aws" {
  region = var.region
}