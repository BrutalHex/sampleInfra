resource "helm_release" "base" {
  name       = "base"
  repository = ""
  chart      = "${path.module}/services/base"
  version    = "0.0.1"
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, helm_release.ingress-nginx, helm_release.cert-manager, kubernetes_namespace.namespace]
  set {
    name  = "cluster.cluster_autoscaler_role"
    value = var.cluster_autoscaler_role
  }
  set {
    name  = "cluster.name"
    value = var.app_name
  }
  set {
    name  = "cluster.aws_region"
    value = var.aws_region
  }
  set {
    name  = "cluster.route53_id"
    value = var.route53_id
  }
  set {
    name  = "cluster.cert_manager_namespace"
    value = var.service_account_name_cert_manager_namespace
  }
  set {
    name  = "domain"
    value = var.domain
  }
  set {
    name  = "cert.email"
    value = var.cert_email
  }
}
