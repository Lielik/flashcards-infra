# ==========================================================
# modules/network/variables.tf
# ----------------------------------------------------------
# Inputs the module expects
# ==========================================================

# -----------------------------
# Name & Tags
# -----------------------------
variable "name" {
  description = "Prefix / base name for network resources"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all network resources"
  type        = map(string)
}

# -----------------------------
# VPC Settings
# -----------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC (e.g. 10.0.0.0/16)"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR (e.g. 10.0.0.0/16)"
  }
}

variable "az_count" {
  description = "Number of Availability Zones to use"
  type        = number
}

variable "enable_nat" {
  description = "Whether to create NAT gateway for private egress"
  type        = bool
}