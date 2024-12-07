locals {
  load-balancer-service-account = "load-balancer-sa"
}


resource "aws_iam_role" "load-balancer" {
  name               = "main_load_balancer"
  assume_role_policy = data.aws_iam_policy_document.load-balancer-aasume.json
  tags               = local.common_tags
}


data "aws_iam_policy_document" "load-balancer-aasume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${local.load-balancer-service-account}", ]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role_policy_attachment" "load-balancer-aasume" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role       = aws_iam_role.load-balancer.name
}