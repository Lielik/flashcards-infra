# modules/proxmox-k8s-cluster/variables.tf
# Input variables for the K8s cluster module

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "template_name" {
  description = "VM template name to clone"
  type        = string
}

# Control plane configuration
variable "control_plane_count" {
  description = "Number of control plane nodes"
  type        = number
}

variable "control_plane_cores" {
  description = "CPU cores for control plane"
  type        = number
}

variable "control_plane_memory" {
  description = "Memory in MB for control plane"
  type        = number
}

variable "control_plane_ips" {
  description = "IP addresses for control plane nodes"
  type        = list(string)
}

# Worker configuration
variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
}

variable "worker_cores" {
  description = "CPU cores for workers"
  type        = number
}

variable "worker_memory" {
  description = "Memory in MB for workers"
  type        = number
}

variable "worker_ips" {
  description = "IP addresses for worker nodes"
  type        = list(string)
}

# Storage
variable "disk_size" {
  description = "Disk size for VMs"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool name"
  type        = string
}

# Network
variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "network_cidr_prefix" {
  description = "CIDR prefix (e.g., 24 for /24)"
  type        = number
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
}

# SSH
variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}
