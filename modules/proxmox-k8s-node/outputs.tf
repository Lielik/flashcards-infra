# modules/proxmox-k8s-node/outputs.tf
# Outputs from the k8s-node module

output "vm_id" {
  description = "Proxmox VM ID"
  value       = proxmox_vm_qemu.k8s_node.vmid
}

output "vm_name" {
  description = "VM name"
  value       = proxmox_vm_qemu.k8s_node.name
}

output "ip_address" {
  description = "VM IP address"
  value       = var.ip_address
}

output "ssh_host" {
  description = "SSH connection string"
  value       = "${var.ssh_user}@${var.ip_address}"
}
