#general variables
variable "aws_region"{
    description = ""
    type = string
    default = "us-east-1"
}

variable "env" {
  description = "environment name (dev/staging/prod)"
  type = string
  default = "dev"
}

#descriptive variables
variable "system_name"{
    description = "The name of the application"
    type = string
    default = "book-inventory"
}

variable "owner_name"{
    description = "The name of the system admin of the application/service"
    type = string
    default = "infra-team"
}

variable "creator_name"{
    description = "Terraform or another infrastructure creator system (AWS CLI / AWS console / other)"
    type = string
    default = "terraform"
}

# ACM vars
variable "domain_name" {
    description = ""
    type = string
    default = "bookteam.net"
}

# API Gateway vars

variable "read_s3_url" {
    description = "The URL of the files bucket to read from"
    type = string
    default = ""#TODO
}
variable "write_s3_url" {
    description = "The URL of the files bucket to put into"
    type = string
    default = ""#TODO
}

# Cognito vars
variable "response_email" {
  description = "email address that sends signup-related messages"
  type = string
  default = "ori.a.shemla@gmail.com"
}

# S3
variable "s3_files_bucket_name_prefix"{
    description = "A name for the S3 bucket of the files (images and pdf)"
    type=string
    default="book-inventory-bucket"
}

variable "s3_temp_files_bucket_name_prefix"{
    description = "A name for the S3 bucket of the temporary files (images and pdf)"
    type=string
    default="book-inventory-bucket-temp"
}
# S3 for Lambda code deploy
variable "s3_lambda_codedeploy_name_prefix"{
    description = "A name for the S3 bucket of the cpde deploy storage of the Lambda functions"
    type=string
    default="book-inventory-code-deploy"
}

#random pet names with suffix for avoiding having buckets with the same name in the same region
resource "random_pet" "s3_files_bucket_name" {
  prefix = var.s3_files_bucket_name_prefix
  length = 2
}
resource "random_pet" "s3_temp_files_bucket_name" {
  prefix = var.s3_temp_files_bucket_name_prefix
  length = 2
}
resource "random_pet" "s3_lambda_codedeploy_name" {
  prefix = var.s3_lambda_codedeploy_name_prefix
  length = 2
}

