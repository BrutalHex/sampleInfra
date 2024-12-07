data "aws_iam_policy_document" "csi-driver" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateSnapshot",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumesModifications"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateVolume",
        "CreateSnapshot"
      ]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:volume/*",
      "arn:aws:ec2:*:*:snapshot/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "aws:RequestTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/CSIVolumeName"
      values   = ["*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeName"
      values   = ["*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVolume"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/kubernetes.io/created-for/pvc/name"
      values   = ["*"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "ec2:ResourceTag/CSIVolumeSnapshotName"
      values   = ["*"]

    }
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteSnapshot"
    ]
    resources = ["*"]
    condition {
      test     = "Null"
      variable = "ec2:ResourceTag/ebs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:CreateGrant"
    ]
    resources = ["*"]
  }
}
locals {
  service-account-name = "csi-driver"
}





resource "aws_iam_role" "csi-driver" {
  name               = "csi-driver"
  assume_role_policy = data.aws_iam_policy_document.csi-driver-service-account.json
  tags = merge(local.common_tags, {
    Name = "${var.app_name}__eks_csi_driver"
  })
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.csi-driver.name
}




resource "aws_iam_policy" "csi-driver-access" {
  name   = "AmazonEKSCsiDriverPolicy"
  path   = "/"
  policy = data.aws_iam_policy_document.csi-driver.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "csi-driver-access" {
  policy_arn = aws_iam_policy.csi-driver-access.arn
  role       = aws_iam_role.csi-driver.name
}


data "aws_iam_policy_document" "csi-driver-service-account" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:${local.service-account-name}", "system:serviceaccount:kube-system:efs-csi-controller-sa", "system:serviceaccount:kube-system:efs-csi-node-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}