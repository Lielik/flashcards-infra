# ==========================================================
# - Locks versions (Terraform + providers) and defines the backend.
# - Configures AWS, Kubernetes, Helm, and kubectl providers.
# - Effect: Terraform can manage AWS infrastructure and Kubernetes resources.
# ==========================================================

terraform {
  backend "s3" {
    # Configuration loaded from env/*.backend.hcl
  }
  required_version = ">= 1.5.0"

  # Lists all the provider plugins Terraform needs to download and install
  required_providers {
    # AWS provider for S3, ECR, Route53, CloudFront
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }

    # Proxmox provider for VM management
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70.0"
    }

    # For local-exec provisioners and triggers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    # For local file generation (Ansible inventory)
    local = {
      source  = "hashicorp/local"
      version = "~> 2.6"
    }
  }
}

# AWS Provider
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

# Proxmox Provider (for Kubernetes VMs)
provider "proxmox" {
  endpoint  = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure  = true

  ssh {
    agent = true
  }
}

# Null Provider - Enables use of null_resource blocks, which run local commands or scripts
provider "null" {}
