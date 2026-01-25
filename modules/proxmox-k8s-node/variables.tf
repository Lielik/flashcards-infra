# modules/proxmox-k8s-node/variables.tf
# Input variables for the k8s-node module

variable "vm_name" {
  description = "VM name"
  type        = string
}

variable "vm_description" {
  description = "VM description"
  type        = string
  default     = "Kubernetes node"
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
}

variable "template_id" {
  description = "Template VM ID to clone from"
  type        = number
}

variable "cpu_cores" {
  description = "CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory (MB)"
  type        = number
}

variable "disk_size" {
  description = "Disk size (not used when cloning, disk comes from template)"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool (not used when cloning)"
  type        = string
}

variable "network_bridge" {
  description = "Network bridge"
  type        = string
}

variable "vlan_tag" {
  description = "VLAN tag (-1 for no VLAN)"
  type        = number
  default     = -1
}

variable "ip_address" {
  description = "Static IP address"
  type        = string
}

variable "cidr_prefix" {
  description = "CIDR prefix (24 for /24)"
  type        = number
  default     = 24
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  default     = ""
}
