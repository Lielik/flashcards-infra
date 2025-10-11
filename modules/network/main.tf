# ==========================================================
# modules/network/main.tf
# ----------------------------------------------------------
# This module builds the VPC, public/private subnets, IGW, NAT,
# route tables and associations. It also tags subnets so that
# AWS Load Balancer Controller can auto-discover them.
# ==========================================================

# -----------------------------
# Data Sources
# -----------------------------

# Fetch availability zones
data "aws_availability_zones" "azs" {}


# -----------------------------
# VPC
# -----------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc"
    }
  )
}


# -----------------------------
# Internet Gateway
# -----------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}


# -----------------------------
# Subnets
# -----------------------------

locals {
  azs = slice(data.aws_availability_zones.azs.names, 0, var.az_count)
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key))
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${each.key}"
      Tier = "public"
      # Tag to designate this subnet as eligible for external load balancers
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in local.azs : idx => az }

  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, tonumber(each.key) + 100)
  availability_zone = each.value

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${each.key}"
      Tier = "private"
      # Tag to designate availability for internal load balancers
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}


# -----------------------------
# Route Tables & Associations (Public)
# -----------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-rt-public"
    }
  )
}

resource "aws_route" "public_to_igw" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


# -----------------------------
# NAT Gateway & Private Routing
# -----------------------------

resource "aws_eip" "nat_eip" {
  count      = var.enable_nat ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat ? 1 : 0
  subnet_id     = values(aws_subnet.public)[0].id
  allocation_id = aws_eip.nat_eip[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat"
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-rt-private"
    }
  )
}

resource "aws_route" "private_to_nat" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
