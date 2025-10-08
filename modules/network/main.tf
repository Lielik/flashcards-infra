# ==========================================================
# modules/network/main.tf
# ----------------------------------------------------------
# Creates the networking layer for the infrastructure:
#   - VPC
#   - Public and private subnets across AZs
#   - Internet Gateway (IGW)
#   - Optional NAT Gateway
#   - Route tables and associations
# ==========================================================


# -----------------------------
# Data Sources
# -----------------------------

data "aws_availability_zones" "this" {}


# -----------------------------
# VPC
# -----------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    { Name = "${var.name}-vpc" }
  )
}


# -----------------------------
# Internet Gateway
# -----------------------------

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-igw" }
  )
}


# -----------------------------
# Subnets
# -----------------------------

locals {
  azs = slice(data.aws_availability_zones.this.names, 0, var.az_count)
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${each.key}"
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key) + 100)
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${each.key}"
      Tier = "private"
    }
  )
}


# -----------------------------
# Route Tables & Associations
# -----------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-rt-public" }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# -----------------------------
# NAT for Private Egress (optional)
# -----------------------------

resource "aws_eip" "nat" {
  count      = var.enable_nat ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    { Name = "${var.name}-eip-nat" }
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_nat ? 1 : 0
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.nat[0].id

  tags = merge(
    var.tags,
    { Name = "${var.name}-nat" }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.name}-rt-private" }
  )
}

resource "aws_route" "private_out" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
