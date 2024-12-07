resource "kubernetes_service_account" "backup-sa" {
  metadata {
    name      = var.backup_service_account_name
    namespace = local.constructed-name
    annotations = {
      "eks.amazonaws.com/role-arn" = "${var.aws_iam_role_backup_bucket_arn}"
    }
  }
}