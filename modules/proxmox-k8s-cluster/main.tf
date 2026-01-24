# modules/proxmox-k8s-cluster/main.tf
# This module provisions a complete Kubernetes cluster on Proxmox
# It creates control plane and worker nodes

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
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

# ==========================================================
# CONTROL PLANE NODES
# ==========================================================

module "control_plane_nodes" {
  source = "../proxmox-k8s-node"

  # Create multiple control plane nodes
  count = var.control_plane_count

  # VM identification
  vm_name        = "${var.cluster_name}-control-${count.index + 1}"
  vm_description = "Kubernetes control plane node ${count.index + 1}"
  vmid           = var.control_plane_vmids[count.index]

  # Proxmox settings
  proxmox_node  = var.proxmox_node
  template_name = var.template_name

  # Resources
  cpu_cores    = var.control_plane_cores
  memory       = var.control_plane_memory
  disk_size    = var.disk_size
  storage_pool = var.storage_pool

  # Network
  network_bridge = var.network_bridge
  ip_address     = var.control_plane_ips[count.index]
  cidr_prefix    = var.network_cidr_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  # SSH
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

# ==========================================================
# WORKER NODES
# ==========================================================

module "worker_nodes" {
  source = "../proxmox-k8s-node"

  # Create multiple worker nodes
  count = var.worker_count

  # VM identification
  vm_name        = "${var.cluster_name}-worker-${count.index + 1}"
  vm_description = "Kubernetes worker node ${count.index + 1}"
  vmid           = var.worker_vmids[count.index]

  # Proxmox settings
  proxmox_node  = var.proxmox_node
  template_name = var.template_name

  # Resources
  cpu_cores    = var.worker_cores
  memory       = var.worker_memory
  disk_size    = var.disk_size
  storage_pool = var.storage_pool

  # Network
  network_bridge = var.network_bridge
  ip_address     = var.worker_ips[count.index]
  cidr_prefix    = var.network_cidr_prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers

  # SSH
  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

# ==========================================================
# WAIT FOR VMs TO BE SSH-READY
# ==========================================================

resource "null_resource" "wait_for_control_plane" {
  count = var.control_plane_count

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for ${module.control_plane_nodes[count.index].vm_name}..."
      for i in {1..60}; do
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
               ${var.ssh_user}@${module.control_plane_nodes[count.index].ip_address} \
               'echo Ready' 2>/dev/null; then
          exit 0
        fi
        sleep 5
      done
      exit 1
    EOT
  }

  depends_on = [module.control_plane_nodes]
}

resource "null_resource" "wait_for_workers" {
  count = var.worker_count

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for ${module.worker_nodes[count.index].vm_name}..."
      for i in {1..60}; do
        if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
               ${var.ssh_user}@${module.worker_nodes[count.index].ip_address} \
               'echo Ready' 2>/dev/null; then
          exit 0
        fi
        sleep 5
      done
      exit 1
    EOT
  }

  depends_on = [module.worker_nodes]
}
