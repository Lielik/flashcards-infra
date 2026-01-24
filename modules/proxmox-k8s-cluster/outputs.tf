# Outputs from the K8s cluster module

output "control_plane_nodes" {
  description = "Control plane node details"
  value = [
    for node in module.control_plane_nodes : {
      name = node.vm_name
      id   = node.vm_id
      ip   = node.ip_address
      ssh  = node.ssh_host
    }
  ]
}

output "worker_nodes" {
  description = "Worker node details"
  value = [
    for node in module.worker_nodes : {
      name = node.vm_name
      id   = node.vm_id
      ip   = node.ip_address
      ssh  = node.ssh_host
    }
  ]
}

output "all_nodes" {
  description = "All cluster nodes"
  value = concat(
    [for node in module.control_plane_nodes : {
      name = node.vm_name
      ip   = node.ip_address
      role = "control-plane"
    }],
    [for node in module.worker_nodes : {
      name = node.vm_name
      ip   = node.ip_address
      role = "worker"
    }]
  )
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (first control plane node)"
  value       = length(module.control_plane_nodes) > 0 ? module.control_plane_nodes[0].ip_address : null
}
