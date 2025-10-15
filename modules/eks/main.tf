# ==========================================================
# modules/eks/main.tf
# ----------------------------------------------------------
# Provisions the EKS cluster, OIDC provider, and managed
# node group resources. Uses descriptive naming, no “this”.
# ==========================================================

# -----------------------------
# EKS Cluster (Control Plane)
# -----------------------------

resource "aws_eks_cluster" "cluster" {
  name     = "${var.name}-eks"
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  tags = var.tags
}


# -----------------------------
# Data Sources (to fetch cluster metadata)
# -----------------------------

data "aws_eks_cluster" "cluster_info" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = aws_eks_cluster.cluster.name
}


# -----------------------------
# IAM OIDC Provider (for IRSA)
# -----------------------------

resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url             = data.aws_eks_cluster.cluster_info.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da0afd10df6"]
}


# -----------------------------
# Managed Node Group (Worker Nodes)
# -----------------------------

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${var.name}-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    min_size     = var.min_size
    desired_size = var.desired_size
    max_size     = var.max_size
  }

  capacity_type  = var.capacity_type
  instance_types = var.instance_types

  tags = var.tags

  depends_on = [aws_iam_openid_connect_provider.oidc_provider]
}


data "aws_iam_policy_document" "ebs_csi_driver" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.oidc_provider.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${aws_eks_cluster.cluster.name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_policy" "ebs_csi_driver_encryption" {
#   name = "${aws_eks_cluster.cluster.name}-ebs-csi-driver-encryption"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:GenerateDataKeyWithoutPlaintext",
#           "kms:CreateGrant"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Optional: only if you want to encrypt the EBS drives
# resource "aws_iam_role_policy_attachment" "ebs_csi_driver_encryption" {
#   policy_arn = aws_iam_policy.ebs_csi_driver_encryption.arn
#   role       = aws_iam_role.ebs_csi_driver.name
# }

# resource "aws_eks_pod_identity_association" "ebs_csi_driver" {
#   cluster_name    = aws_eks_cluster.cluster.name
#   namespace       = "kube-system"
#   service_account = "ebs-csi-controller-sa"
#   role_arn        = aws_iam_role.ebs_csi_driver.arn
# }

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.50.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [aws_iam_openid_connect_provider.oidc_provider]
}
