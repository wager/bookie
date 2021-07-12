# An S3 Terraform backend.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.49.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# A S3 bucket that stores the Terraform state.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "wager-terraform"
  acl    = "private"
  tags   = { Name = "Terraform State" }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# A DynamoDB table that is used to synchronize operations on the Terraform state.
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20
  tags           = { Name = "Terraform Lock" }

  attribute {
    name = "LockID"
    type = "S"
  }
}
