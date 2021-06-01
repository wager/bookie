# A platform built on Amazon Web Services.
terraform {
  backend "s3" {
    bucket         = "wager-terraform"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    key            = "platform/terraform.tfstate"
    region         = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.31.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# A virtual private cloud.
resource "aws_vpc" "vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# A publicly visible subnet.
resource "aws_subnet" "public" {
  availability_zone       = var.aws_availability_zone
  cidr_block              = "10.1.0.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

# A firewall configuration for Vagrant boxes.
resource "aws_security_group" "vagrant" {
  name   = "vagrant"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow incoming SSH."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow incoming Jupyter."
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outgoing."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
