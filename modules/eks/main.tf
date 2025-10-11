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
