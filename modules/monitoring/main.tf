terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}


# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# Create logging namespace
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}

resource "time_sleep" "wait_for_cluster" {
  create_duration = "30s"
}

# Deploy Prometheus stack
resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  create_namespace = true
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  version          = "78.3.2" # Pin version for stability

  timeout = 900
  wait    = true

  values = [
    file("${path.module}/helm-values/prometheus-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.monitoring,
    time_sleep.wait_for_cluster
  ]
}

# Deploy Elasticsearch
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "8.5.1"

  timeout = 900
  wait    = true

  values = [
    file("${path.module}/helm-values/elasticsearch-values.yaml")
  ]

  depends_on = [
    kubernetes_namespace.logging,
    time_sleep.wait_for_cluster
  ]
}

# Deploy Fluent Bit
resource "helm_release" "fluent_bit" {
  name       = "fluent-bit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "0.54.0"

  timeout = 600
  wait    = true

  values = [
    file("${path.module}/helm-values/fluent-bit-values.yaml")
  ]

  depends_on = [helm_release.elasticsearch]
}

# Deploy Kibana
resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  namespace  = kubernetes_namespace.logging.metadata[0].name
  version    = "8.5.1"

  timeout = 900
  wait    = true

  values = [
    file("${path.module}/helm-values/kibana-values.yaml")
  ]

  depends_on = [helm_release.elasticsearch]
}
