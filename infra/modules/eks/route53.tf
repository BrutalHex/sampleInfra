
resource "aws_route53_zone" "eks" {
  name = var.aws_route53_domain
}

locals {
  service_account_name_external_dns           = "externaldns-sa"
  service_account_name_cert_manager           = "cert-manager-sa"
  service_account_name_cert_manager_namespace = "cert-manager"
}

data "aws_iam_policy_document" "route53" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListTagsForResource",
      "route53:ListResourceRecordSets",
      "route53:GetChange",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "route53" {
  name               = "${var.app_name}__eks_route53"
  assume_role_policy = data.aws_iam_policy_document.route53-service-account.json
  tags = merge(local.common_tags, {
    Name = "${var.app_name}__eks_route53"
  })
}

resource "aws_iam_policy" "route53" {
  name   = "AmazonEKSRoute53Policy"
  path   = "/"
  policy = data.aws_iam_policy_document.route53.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "route53-access" {
  policy_arn = aws_iam_policy.route53.arn
  role       = aws_iam_role.route53.name
}

data "aws_iam_policy_document" "route53-service-account" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${local.service_account_name_external_dns}", "system:serviceaccount:${local.service_account_name_cert_manager_namespace}:${local.service_account_name_cert_manager}"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}