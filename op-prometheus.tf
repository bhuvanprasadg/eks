resource "kubernetes_namespace" "prometheus_ns" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus" {
  chart      = "kube-prometheus-stack"
  name       = "prometheus"
  namespace  = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"

  values = [
    templatefile("${path.module}/operator-values/prometheus.tpl", {
    })
  ]
}