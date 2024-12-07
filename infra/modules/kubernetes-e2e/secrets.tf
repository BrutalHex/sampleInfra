locals {
  service-name = "postgres"
  database = {
    username = "admin"
    port     = "5432"
    store    = "maindb"
    host     = "${local.service-name}.${local.constructed-name}.svc.cluster.local"
  }
}


resource "random_password" "postgres-password" {
  length  = 32
  special = true
}

resource "kubernetes_secret" "postgres-access" {
  metadata {
    name      = "postgres-secret"
    namespace = local.constructed-name
  }

  data = {
    password   = random_password.postgres-password.result
    connection = "postgresql://${local.database.username}:${random_password.postgres-password.result}@${local.service-name}.${local.constructed-name}.svc.cluster.local:${local.database.port}/${local.database.store}"
  }
}