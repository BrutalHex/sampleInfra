resource "helm_release" "ingress-nginx" {
  depends_on = [helm_release.aws_ebs_csi_driver, helm_release.external-dns, kubernetes_namespace.namespace]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.namespaces_nginx
  values = [
    <<EOF
controller:
  service:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: external
      service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: ip
      service.beta.kubernetes.io/aws-load-balancer-ip-address-type: ipv4
      service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
  extraArgs: 
    default-ssl-certificate: "${var.service_account_name_cert_manager_namespace}/${var.domain}-tls"
EOF
  ]
}



