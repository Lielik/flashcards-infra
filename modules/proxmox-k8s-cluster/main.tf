# modules/proxmox-k8s-cluster/main.tf
# This module provisions a complete Kubernetes cluster on Proxmox
# It creates control plane and worker nodes

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# Control Plane Nodes
module "control_plane_nodes" {
  source = "../proxmox-k8s-node"
  count  = var.control_plane_count

  vm_name        = "${var.cluster_name}-control-${count.index + 1}"
  vm_description = "Kubernetes control plane node ${count.index + 1}"

  proxmox_node = var.proxmox_node
  template_id  = var.template_id

  cpu_cores    = var.control_plane_cores
  memory       = var.control_plane_memory
  disk_size    = var.disk_size
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  ip_address     = var.control_plane_ips[count.index]
  cidr_prefix    = var.network_cidr_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

# Worker Nodes
module "worker_nodes" {
  source = "../proxmox-k8s-node"
  count  = var.worker_count

  vm_name        = "${var.cluster_name}-worker-${count.index + 1}"
  vm_description = "Kubernetes worker node ${count.index + 1}"

  proxmox_node = var.proxmox_node
  template_id  = var.template_id

  cpu_cores    = var.worker_cores
  memory       = var.worker_memory
  disk_size    = var.disk_size
  storage_pool = var.storage_pool

  network_bridge = var.network_bridge
  ip_address     = var.worker_ips[count.index]
  cidr_prefix    = var.network_cidr_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}
