# Enable remote backend for Terraform using AWS S3 and DynamoDB
# based on https://github.com/sidpalas/devops-directive-terraform-course/blob/main/03-basics/aws-backend/main.tf
# based on https://www.youtube.com/watch?v=7xngnjfIlK4

resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.devops_s3_name # BUCKET NAME
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "terraform_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_crypto_conf" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.devops_dynamodb_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}