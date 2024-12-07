data "aws_eks_cluster" "eks_status" {
  # This is a trick to make sure cluster is ready.
  depends_on = [aws_eks_cluster.eks]
  name       = aws_eks_cluster.eks.name
}
resource "aws_eks_node_group" "eks" {
  cluster_name    = data.aws_eks_cluster.eks_status.name
  node_group_name = "eks"
  node_role_arn   = aws_iam_role.node_group_eks.arn
  subnet_ids      = [for item in aws_subnet.public_subnet : item.id]
  instance_types  = ["t2.small"]
  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  depends_on = [
    aws_iam_role_policy_attachment.node_group_eks_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_group_eks_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_group_eks_AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = merge(local.common_tags, {
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.name}" = "owned",
    "k8s.io/cluster-autoscaler/enabled"                     = "true"
  })
}

resource "aws_iam_role" "node_group_eks" {
  name               = "eks_node_group_eks"
  assume_role_policy = data.aws_iam_policy_document.node_group_eks.json
  tags               = local.common_tags
}


data "aws_iam_policy_document" "node_group_eks" {
  statement {
    actions = ["sts:AssumeRole", "sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
  version = "2012-10-17"
}


resource "aws_iam_role_policy_attachment" "node_group_eks_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_eks.name
}

resource "aws_iam_role_policy_attachment" "node_group_eks_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_eks.name
}

resource "aws_iam_role_policy_attachment" "node_group_eks_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_eks.name
}

resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.aws_iam_policy_document.load_balancer_controller_IAM_policy.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "node_nlb" {
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
  role       = aws_iam_role.node_group_eks.name
}

