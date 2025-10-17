output "prometheus_url" {
  description = "Prometheus service URL portforwarded"
  value       = "http://localhost:9090"
}

output "grafana_url" {
  description = "Grafana service URL portforwarded"
  value       = "http://localhost:80"
}

output "kibana_url" {
  description = "Kibana service URL portforwarded"
  value       = "http://locslhost:5601"
}

output "elasticsearch_url" {
  description = "Elasticsearch service URL portforwarded"
  value       = "http://localhost:9200"
}
