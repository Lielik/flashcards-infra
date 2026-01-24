# modules/proxmox-k8s-node/variables.tf
# Input variables for the k8s-node module

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "vm_description" {
  description = "Description of the VM"
  type        = string
  default     = "Kubernetes node"
}

variable "vmid" {
  description = "Proxmox VMID"
  type        = number
}

variable "proxmox_node" {
  description = "Proxmox node name where VM will be created"
  type        = string
}

variable "template_name" {
  description = "Name of the template to clone"
  type        = string
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
}

variable "memory" {
  description = "Memory in MB"
  type        = number
}

variable "disk_size" {
  description = "Disk size (e.g., '32G')"
  type        = string
}

variable "storage_pool" {
  description = "Storage pool for disks"
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
  description = "Static IP address for the VM"
  type        = string
}

variable "cidr_prefix" {
  description = "CIDR prefix (e.g., 24 for /24)"
  type        = number
  default     = 24
}

variable "gateway" {
  description = "Network gateway"
  type        = string
}

variable "dns_servers" {
  description = "List of DNS servers"
  type        = list(string)
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key (optional, uses template key if empty)"
  type        = string
  default     = ""
}
