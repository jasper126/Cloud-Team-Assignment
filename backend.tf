terraform {
  backend "s3" {
    bucket            = "tf-state-test-jp"
    key               = "terraform.tfstate"
    region            = "us-east-1"
    dynamodb_table    = "terraformlocks"
    encrypt           = true
  }
}
provider "aws" {
    region = "us-east-1"
  
}
resource "aws_s3_bucket" "terraformstate" {
    bucket        = "tf-state-test-jp"
    force_destroy = true
    }
resource "aws_s3_bucket_server_side_encryption_configuration" "terraformstate" {
  bucket = aws_s3_bucket.terraformstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_versioning" "terraformstate" {
  bucket    = aws_s3_bucket.terraformstate.id
  versioning_configuration {
    status = "Enabled"
  }

}
resource "aws_dynamodb_table" "terraformlocks" {
    name          = "terraform-state-locking"
    billing_mode  = "PAY_PER_REQUEST"
    hash_key      = "lockID"
    attribute {
      name        = "lockID"
      type        = "S"
    }
  
}