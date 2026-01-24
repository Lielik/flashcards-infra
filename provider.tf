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
      version = "~> 6.16.0"
    }

    # Proxmox provider for VM management
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }

    # For local-exec provisioners and triggers
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    # For local file generation (Ansible inventory)
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
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
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true

  # Enable debug logging
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

# Null Provider - Enables use of null_resource blocks, which run local commands or scripts
provider "null" {}
