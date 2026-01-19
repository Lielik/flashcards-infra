# ==========================================================
# Persistent Infrastructure
# Resources that should survive daily destroy/apply cycles
# ==========================================================

terraform {
  backend "s3" {
    # Will be configured via backend.hcl
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  name_prefix = "${var.project}-${var.env}"

  tags = {
    Project     = var.project
    Environment = var.env
    ManagedBy   = "terraform"
    Layer       = "persistent"
  }
}

# ==========================================================
# S3 Bucket for Static Files (Persistent)
# ==========================================================

resource "aws_s3_bucket" "static_files" {
  bucket = "${local.name_prefix}-static-files"

  tags = merge(
    local.tags,
    {
      Name    = "${local.name_prefix}-static-files"
      Purpose = "static-web-hosting"
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "static_files" {
  bucket = aws_s3_bucket.static_files.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "static_files" {
  bucket = aws_s3_bucket.static_files.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "static_files" {
  bucket = aws_s3_bucket.static_files.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "static_files" {
  bucket = aws_s3_bucket.static_files.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_files.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.static_files]
}
