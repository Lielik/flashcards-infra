# variables.tf
# Input variable declarations (values provided in env/*.tfvars)
# ==========================================================

# ==========================================================
# PROJECT CONFIGURATION
# ==========================================================

variable "project" {
  description = "Project name (used for naming & tagging)"
  type        = string
}

variable "env" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

# ==========================================================
# AWS SERVICES (S3, ECR, Route53, CloudFront)
# ==========================================================

variable "region" {
  description = "AWS region for AWS resources (S3, ECR, Route53)"
  type        = string
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for container images"
  type        = string
}

# ==========================================================
# PROXMOX CONFIGURATION
# ==========================================================

variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID (format: user@realm!tokenname)"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

# ==========================================================
# KUBERNETES CLUSTER CONFIGURATION
# ==========================================================

variable "k8s_cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "k8s_control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
}

variable "k8s_worker_count" {
  description = "Number of worker nodes"
  type        = number
}

# ==========================================================
# VM TEMPLATE CONFIGURATION
# ==========================================================

variable "vm_template_name" {
  description = "Name of the VM template to clone"
  type        = string
}

variable "vm_template_id" {
  description = "Template VM ID"
  type        = number
}

# ==========================================================
# VM RESOURCES
# ==========================================================

variable "control_plane_cores" {
  description = "CPU cores for control plane nodes"
  type        = number
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane nodes"
  type        = number
}

variable "worker_cores" {
  description = "CPU cores for worker nodes"
  type        = number
}

variable "worker_memory" {
  description = "Memory in MB for worker nodes"
  type        = number
}

variable "vm_disk_size" {
  description = "Disk size for VMs"
  type        = string
}

variable "vm_storage" {
  description = "Storage pool for VM disks"
  type        = string
}

# ==========================================================
# NETWORK CONFIGURATION
# ==========================================================

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "network_gateway" {
  description = "Network gateway"
  type        = string
}

variable "network_cidr" {
  description = "Network CIDR"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
}

variable "control_plane_ips" {
  description = "IP addresses for control plane nodes"
  type        = list(string)
}

variable "worker_ips" {
  description = "IP addresses for worker nodes"
  type        = list(string)
}

# =========================
# Proxmox VMID allocation
# =========================

variable "control_plane_vmids" {
  description = "Explicit VMIDs for control plane nodes"
  type        = list(number)
}

variable "worker_vmids" {
  description = "Explicit VMIDs for worker nodes"
  type        = list(number)
}

# ==========================================================
# SSH CONFIGURATION
# ==========================================================

variable "ssh_user" {
  description = "SSH user for VMs"
  type        = string
}

variable "ssh_public_key_file" {
  description = "Path to SSH public key file"
  type        = string
}
