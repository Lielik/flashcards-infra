# ==========================================================
# variables.tf
# ----------------------------------------------------------
# - Declares all required inputs (no defaults): project/env/region, VPC CIDR, and EKS node group settings.
# - These are referenced by main.tf and passed down to modules.
# - Effect: Forces you to drive configuration from env/*.tfvars so everything is explicit and environment-specific.
# ==========================================================


# -----------------------------
# Project & Environment
# -----------------------------

variable "project" {
  description = "Project name (e.g., flashcards)"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "region" {
  description = "AWS region (e.g., eu-central-1)"
  type        = string
}


# -----------------------------
# Networking
# -----------------------------

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR, e.g., 10.0.0.0/16."
  }
}


# -----------------------------
# EKS Node Group
# -----------------------------

variable "instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of worker nodes in the EKS node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "capacity_type" {
  description = "Capacity type for EKS nodes (ON_DEMAND or SPOT)"
  type        = string
}
