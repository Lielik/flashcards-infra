# -----------------------------
# Name & Tags
# -----------------------------
variable "name" {
  description = "Base name prefix for cluster and resources"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to EKS resources"
  type        = map(string)
}

# -----------------------------
# Network & IAM Inputs
# -----------------------------
variable "vpc_id" {
  description = "VPC ID that EKS will be deployed into"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for EKS and its nodes"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "node_role_arn" {
  description = "IAM role ARN used by worker nodes"
  type        = string
}

# -----------------------------
# Node Group Settings
# -----------------------------
variable "instance_types" {
  description = "EC2 instance types for nodes"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes"
  type        = number
}

variable "capacity_type" {
  description = "Capacity type for nodes: ON_DEMAND or SPOT"
  type        = string
}
