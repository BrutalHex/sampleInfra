

locals {
  namespaces = [
    var.namespaces_nginx,
    var.service_account_name_cert_manager_namespace,
  ]
}



resource "kubernetes_namespace" "namespace" {
  for_each = toset(local.namespaces)
  lifecycle {
    ignore_changes = [metadata]
  }

  metadata {
    name = each.value
    labels = {
      "${var.app_name}" = "true"
    }
  }
}

resource "time_sleep" "destroy_wait_5_minute" {
  depends_on       = [kubernetes_namespace.namespace]
  destroy_duration = "10s"
}
