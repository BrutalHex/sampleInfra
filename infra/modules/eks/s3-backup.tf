locals {
  service_account_name_backup_bucket = "s3-backup-bucket-sa"
}

data "aws_iam_policy_document" "s3-backup" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:*"
    ]

    resources = [
      var.aws_s3_bucket_backup_arn
    ]
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]

    resources = [
      "${var.aws_s3_bucket_backup_arn}/*",
    ]
  }


  statement {
    effect = "Deny"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]
    resources = [
      "${var.aws_s3_bucket_backup_arn}/*",
    ]
  }
}

resource "aws_iam_role" "s3-backup" {
  name               = "${var.app_name}__eks_s3_backup"
  assume_role_policy = data.aws_iam_policy_document.s3-backup-service-account.json
  tags = merge(local.common_tags, {
    Name = "${var.app_name}__eks_s3_backup"
  })
}




resource "aws_iam_policy" "s3-backup" {
  name   = "AmazonEKSs3-backupPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.s3-backup.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "s3-backup-access" {
  policy_arn = aws_iam_policy.s3-backup.arn
  role       = aws_iam_role.s3-backup.name
}


data "aws_iam_policy_document" "s3-backup-service-account" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringLike"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:*:${local.service_account_name_backup_bucket}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}