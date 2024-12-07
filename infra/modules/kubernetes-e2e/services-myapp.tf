resource "random_pet" "release_suffix" {
  length = 5
}

locals {
  constructed-name = "${var.app_name}-${random_pet.release_suffix.id}"
  domain           = "${random_pet.release_suffix.id}.${var.domain}"
}


resource "kubernetes_namespace" "app_namespace" {
  lifecycle {
    ignore_changes = [metadata]
  }
  metadata {
    name = local.constructed-name
    labels = {
      "${var.app_name}" = "true"
    }
  }
}

resource "time_sleep" "destroy_wait_5_minute_app_namespace" {
  depends_on       = [local.constructed-name]
  destroy_duration = "10s"
}




resource "helm_release" "myapp" {
  name       = local.constructed-name
  repository = ""
  chart      = "${path.module}/services/myapp"
  version    = "0.0.1"
  depends_on = [kubernetes_namespace.app_namespace]
  set {
    name  = "app.namespaces"
    value = local.constructed-name
  }
  # For demo purposes, terraform variables has been skipped 
  set {
    name  = "app.name"
    value = "myapp"
  }
  set {
    name  = "app.image"
    value = var.app_image
  }
  set {
    name  = "ingress.className"
    value = "nginx"
  }
  set {
    name  = "ingress.url"
    value = local.domain
  }


  set {
    name  = "postgres.passwordSecretName"
    value = kubernetes_secret.postgres-access.metadata[0].name
  }

  set {
    name  = "postgres.backupBucketArn"
    value = var.aws_s3_bucket_backup_arn
  }
  set {
    name  = "postgres.backupFile"
    value = var.aws_s3_bucket_backup_file
  }

  set {
    name  = "postgres.sa"
    value = var.backup_service_account_name
  }
  set {
    name  = "postgres.serviceName"
    value = local.service-name
  }
  set {
    name  = "postgres.databaseName"
    value = local.database.store
  }
  set {
    name  = "postgres.port"
    value = local.database.port
  }
  set {
    name  = "postgres.user"
    value = local.database.username
  }
}
