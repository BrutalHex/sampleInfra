
resource "aws_eks_cluster" "eks" {
  name                      = var.app_name
  role_arn                  = aws_iam_role.eks_direct_iam.arn
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    subnet_ids = [for item in aws_subnet.public_subnet : item.id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
    aws_iam_role_policy_attachment.eks_AmazonEKSVPCResourceController,
  ]
  tags = merge(local.common_tags,
    {
      Name = "${var.app_name}"
    }
  )
}

data "aws_eks_cluster_auth" "eks" {
  name = "eks_auth"
  depends_on = [
    aws_eks_cluster.eks
  ]
}



resource "aws_iam_role" "eks_direct_iam" {
  name               = "eks_direct_iam"
  assume_role_policy = data.aws_iam_policy_document.eks_direct_iam_policy.json
  tags = merge(local.common_tags, {
    Name = "${var.app_name}_eks_direct_iam"
  })
}

data "aws_iam_policy_document" "eks_direct_iam_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_direct_iam.name
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_direct_iam.name
}






 