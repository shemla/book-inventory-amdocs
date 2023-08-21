# infrastructure to enable auto deploy of the lambda code from the repository
module "s3_lambda_codedeploy" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = random_pet.s3_lambda_codedeploy_name.id
  acl    = "private"
  force_destroy =true
  versioning = {
    enabled = true
  }
  tags = {
    function=local.tag_function_infra
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
}

#restful handler lambda
data "archive_file" "restful_handler_lambda" {
  type = "zip"

  source_dir  = "${path.module}/../code/restful_handler_lambda"
  output_path = "${path.module}/../code/restful_handler_lambda.zip"
}
resource "aws_s3_object" "restful_handler_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "restful_handler_lambda.zip"
  source = data.archive_file.restful_handler_lambda.output_path

  etag = filemd5(data.archive_file.restful_handler_lambda.output_path)
}

#error lambda
data "archive_file" "error_lambda" {
  type = "zip"

  source_dir  = "${path.module}/../code/error_lambda"
  output_path = "${path.module}/../code/error_lambda.zip"
}
resource "aws_s3_object" "error_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "error_lambda.zip"
  source = data.archive_file.error_lambda.output_path

  etag = filemd5(data.archive_file.error_lambda.output_path)
}

#db search lambda
data "archive_file" "db_search_lambda" {
  type = "zip"

  source_dir  = "${path.module}/../code/db_search_lambda"
  output_path = "${path.module}/../code/db_search_lambda.zip"
}
resource "aws_s3_object" "db_search_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "db_search_lambda.zip"
  source = data.archive_file.db_search_lambda.output_path

  etag = filemd5(data.archive_file.db_search_lambda.output_path)
}

#finalize testing lambda
data "archive_file" "finalize_testing_lambda" {
  type = "zip"

  source_dir  = "${path.module}/../code/finalize_testing_lambda"
  output_path = "${path.module}/../code/finalize_testing_lambda.zip"
}
resource "aws_s3_object" "finalize_testing_lambda" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "finalize_testing_lambda.zip"
  source = data.archive_file.finalize_testing_lambda.output_path

  etag = filemd5(data.archive_file.finalize_testing_lambda.output_path)
}
