variable "enable_logging" {
  description = "Enable logging stack (Elasticsearch, Fluent Bit, Kibana)"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana)"
  type        = bool
  default     = true
}
