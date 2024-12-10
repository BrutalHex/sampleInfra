
resource "kubernetes_service_account" "csi-driver-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.csi_driver_service_account_name
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.aws_iam_role_csi_driver_arn}"
    }
  }
}

resource "kubernetes_service_account" "route53-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.route53_service_account_name_external_dns
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.aws_iam_role_route53_arn}"
    }
  }
}

resource "kubernetes_service_account" "load-balancer-kube-system" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.load_balancer_service_account
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.aws_iam_role_load_balancer_arn}"
    }
  }
}


resource "kubernetes_service_account" "route53-cert-manager" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = var.service_account_name_cert_manager
    namespace = var.service_account_name_cert_manager_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.aws_iam_role_route53_arn}"
    }
  }
}

