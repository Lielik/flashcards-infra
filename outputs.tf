# ==========================================================
#   - Expose key identifiers and connection details from all modules
#   - Provide ready-to-run convenience commands for interacting
#     with the EKS cluster and verifying the deployment
# ==========================================================


# -----------------------------
# AWS RESOURCES
# -----------------------------
output "ecr_repository_url" {
  description = "URL of the existing ECR repository"
  value       = data.aws_ecr_repository.existing.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the existing ECR repository"
  value       = data.aws_ecr_repository.existing.arn
}


# Static Files S3 Bucket Outputs
output "static_files_bucket_name" {
  description = "Name of the S3 bucket for static files"
  value       = data.aws_s3_bucket.static_files.id
}

output "static_files_bucket_endpoint" {
  description = "S3 bucket regional domain name"
  value       = data.aws_s3_bucket.static_files.bucket_regional_domain_name
}

output "static_files_website_url" {
  description = "S3 website endpoint URL"
  value       = "http://${data.aws_s3_bucket.static_files.bucket_regional_domain_name}"
}

output "upload_static_files_command" {
  description = "Command to upload static files to S3"
  value       = "aws s3 sync ./static/ s3://${data.aws_s3_bucket.static_files.id}/ --delete --region ${var.region}"
}

# ==========================================================
# KUBERNETES CLUSTER
# ==========================================================

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.k8s_cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.k8s_cluster.cluster_endpoint
}

output "control_plane_nodes" {
  description = "Control plane nodes"
  value       = module.k8s_cluster.control_plane_nodes
}

output "worker_nodes" {
  description = "Worker nodes"
  value       = module.k8s_cluster.worker_nodes
}

output "all_nodes" {
  description = "All cluster nodes"
  value       = module.k8s_cluster.all_nodes
}

# ==========================================================
# ANSIBLE
# ==========================================================

output "ansible_inventory" {
  description = "Ansible inventory file path"
  value       = local_file.ansible_inventory.filename
}

output "next_steps" {
  description = "What to do next"
  value       = <<-EOT
  
  Kubernetes VMs provisioned!
  
  Next Steps:
  
  1. Test SSH connectivity:
     ssh ${var.ssh_user}@${module.k8s_cluster.cluster_endpoint}
  
  2. Test Ansible:
     ansible -i ${local_file.ansible_inventory.filename} all -m ping
  
  3. Install Kubernetes with Ansible (coming next!)
  
  EOT
}
