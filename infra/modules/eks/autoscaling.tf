resource "aws_iam_policy" "AmazonEKSClusterAutoscalerPolicy" {
  name   = "AmazonEKSClusterAutoscalerPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.cluster_autoscaler_node_policy.json
  tags   = local.common_tags
}

data "aws_iam_policy_document" "cluster_autoscaler_node_policy" {
  version = "2012-10-17"
  statement {
    sid    = "item1"
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.name}"
      values   = ["owned"]
    }
  }
  statement {
    sid    = "item2"
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeLaunchConfigurations",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_sts_policy.json
  tags               = local.common_tags
}
data "aws_iam_policy_document" "cluster_autoscaler_sts_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role_policy_attachment" "autoscale" {
  policy_arn = aws_iam_policy.AmazonEKSClusterAutoscalerPolicy.arn
  role       = aws_iam_role.cluster_autoscaler.name
}

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity.0.oidc.0.issuer
}
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  url             = data.tls_certificate.eks.url
  tags            = local.common_tags
}

resource "aws_security_group_rule" "eks-add-clustersg" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  security_group_id        = aws_security_group.eks.id
}

 