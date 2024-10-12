resource "kubernetes_namespace" "metrics-server" {
  metadata {
    name = "metrics-server"
  }
}

resource "helm_release" "metrics-server" {
  chart      = "metrics-server"
  name       = "metrics-server"
  namespace  = kubernetes_namespace.metrics-server.metadata[0].name
  repository = "https://kubernetes-sigs.github.io/metrics-server/"

  values = [
    templatefile("${path.module}/operator-values/metrics-server.tpl", {
    })
  ]
}