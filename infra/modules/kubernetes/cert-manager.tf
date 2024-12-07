resource "helm_release" "cert-manager" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, kubernetes_namespace.namespace]
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = var.service_account_name_cert_manager_namespace
  values = [
    <<EOF
crds:
  enabled: true
  keep: true
replicaCount: 1
serviceAccount:
  create: false
  name: ${var.service_account_name_cert_manager}
EOF
  ]
}