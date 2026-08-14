resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "monitoring"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_version # You can update this as needed

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",  # required for some EKS setups
        "--kubelet-preferred-address-types=InternalIP"
      ]
    })
  ]

  set {
    name  = "metrics.enabled"
    value = "true"
  }
}
