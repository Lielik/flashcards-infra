# ==========================================================
# modules/registry/main.tf
# ----------------------------------------------------------
# Creates an AWS ECR repository with on-push image scanning.
# ==========================================================

resource "aws_ecr_repository" "this" {
  name                 = var.repository
  force_delete         = var.force_delete
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    { Name = "${var.name}-ecr" }
  )
}
