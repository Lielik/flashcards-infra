# ==========================================================
# modules/network/variables.tf
# ----------------------------------------------------------
# Inputs the module expects
# No defaults: all values must come from root module.
# ==========================================================

variable "name" {
  description = "Base name/prefix for resources (e.g., flashcards-dev)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR, e.g., 10.0.0.0/16."
  }
}

variable "az_count" {
  description = "Number of Availability Zones to span (e.g., 2)"
  type        = number
}

variable "enable_nat" {
  description = "Whether to create a NAT gateway for private subnets"
  type        = bool
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
}
