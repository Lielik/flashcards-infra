# modules/proxmox-k8s-node/main.tf
# This module creates a single Kubernetes node VM by cloning the template

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

# Create VM by cloning the cloud-init template
resource "proxmox_vm_qemu" "k8s_node" {
  # VM identification
  name        = var.vm_name
  desc        = var.vm_description
  target_node = var.proxmox_node

  # Clone from template
  clone = var.template_name

  # Full clone (not linked clone) for independence
  full_clone = true

  # VM will start automatically after creation
  onboot = true

  # Agent for better integration (qemu-guest-agent in template)
  agent = 1

  # CPU configuration
  cores   = var.cpu_cores
  sockets = 1
  cpu     = "host" # Use host CPU type for better performance

  # Memory configuration (in MB)
  memory = var.memory

  # Enable NUMA (better performance for multi-socket systems)
  numa = false

  # Disk configuration
  disks {
    ide {
      # IDE controller for cloud-init drive
      ide2 {
        cloudinit {
          storage = var.storage_pool
        }
      }
    }

    scsi {
      # Main disk
      scsi0 {
        disk {
          size    = var.disk_size
          storage = var.storage_pool
          # Discard for thin provisioning
          discard = true
          # Enable IO thread for better performance
          iothread = true
        }
      }
    }
  }

  # Network configuration
  network {
    model  = "virtio" # Virtio for better performance
    bridge = var.network_bridge
    tag    = var.vlan_tag
  }

  # Cloud-init configuration
  # This configures the VM on first boot
  ipconfig0 = "ip=${var.ip_address}/${var.cidr_prefix},gw=${var.gateway}"

  # DNS nameservers
  nameserver = join(" ", var.dns_servers)

  # SSH configuration
  # The SSH key is already in the template, but we can override it
  sshkeys = var.ssh_public_key != "" ? var.ssh_public_key : null

  # Cloud-init user (ubuntu is default in template)
  ciuser = var.ssh_user

  # Lifecycle management
  lifecycle {
    ignore_changes = [
      # Ignore network changes (IP might change during testing)
      network,
      # Ignore disk changes after creation
      disks,
    ]
  }
}
