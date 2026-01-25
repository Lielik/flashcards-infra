# modules/proxmox-k8s-node/main.tf
# This module creates a single Kubernetes node VM by cloning the template

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70.0"
    }
  }
}

# Create VM by cloning the cloud-init template
resource "proxmox_virtual_environment_vm" "k8s_node" {
  name        = var.vm_name
  description = var.vm_description
  node_name   = var.proxmox_node

  # Clone from template
  clone {
    vm_id = var.template_id
    full  = true
  }

  # CPU
  cpu {
    cores = var.cpu_cores
  }

  # Memory
  memory {
    dedicated = var.memory
  }

  # Network
  network_device {
    bridge  = var.network_bridge
    vlan_id = var.vlan_tag != -1 ? var.vlan_tag : null
  }

  # Cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.cidr_prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_account {
      username = var.ssh_user
      keys     = [var.ssh_public_key]
    }
  }

  # Start VM after creation
  started = true

  # Agent for better integration
  agent {
    enabled = true
  }
}
