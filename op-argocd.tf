resource "kubernetes_namespace" "argocd-ns" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  chart      = "argo-cd"
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"

  values = [
    templatefile("${path.module}/operator-values/argocd.tpl", {
    })
  ]
}

