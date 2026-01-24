# flashcards-infra/main.tf
# -----------------------------
# Local Naming & Tagging
# -----------------------------

locals {
  name_prefix = "${var.project}-${var.env}"

  tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
  }
}

# ==========================================================
# AWS RESOURCES (S3, ECR, Route53)
# ==========================================================

# Reference existing S3 bucket (created in persistent/)
data "aws_s3_bucket" "static_files" {
  bucket = "${local.name_prefix}-static-files"
}

# Reference existing ECR repository (or create if needed)
data "aws_ecr_repository" "app" {
  name = var.ecr_repository_name
}


## ==========================================================
# PROXMOX KUBERNETES CLUSTER
# ==========================================================

module "k8s_cluster" {
  source = "./modules/proxmox-k8s-cluster"

  # Cluster configuration
  cluster_name  = var.k8s_cluster_name
  proxmox_node  = var.proxmox_node
  template_name = var.vm_template_name

  # Control plane
  control_plane_count  = var.k8s_control_plane_count
  control_plane_cores  = var.control_plane_cores
  control_plane_memory = var.control_plane_memory
  control_plane_ips    = var.control_plane_ips
  control_plane_vmids  = var.control_plane_vmids

  # Workers
  worker_count  = var.k8s_worker_count
  worker_cores  = var.worker_cores
  worker_memory = var.worker_memory
  worker_ips    = var.worker_ips
  worker_vmids  = var.worker_vmids

  # Storage
  disk_size    = var.vm_disk_size
  storage_pool = var.vm_storage

  # Network
  network_bridge      = var.network_bridge
  network_cidr_prefix = tonumber(split("/", var.network_cidr)[1])
  gateway             = var.network_gateway
  dns_servers         = var.dns_servers

  # SSH
  ssh_user       = var.ssh_user
  ssh_public_key = file(var.ssh_public_key_file)
}


# ==========================================================
# ANSIBLE INVENTORY GENERATION
# ==========================================================

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/ansible/inventory/hosts.ini"
  file_permission = "0600"

  content = templatefile("${path.module}/templates/ansible_inventory.tpl", {
    control_plane_nodes = module.k8s_cluster.control_plane_nodes
    worker_nodes        = module.k8s_cluster.worker_nodes
    cluster_name        = var.k8s_cluster_name
    ssh_user            = var.ssh_user
  })

  depends_on = [module.k8s_cluster]
}
