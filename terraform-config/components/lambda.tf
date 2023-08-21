# In this file:
# restful-handler lambda
# db-search lambda
# 
# data-related lambdas:
# - crud-author
# - crud-publisher
# - crud-branch
# - crud-vendor
# - create-bookItem
# - read-bookItem
# - update-bookItem
# - archive-bookItem
# - create-book
# - read-book
# - update-book
# - archive-book
# - create-userAction
# - read-userActions
# - update-userAction
# - create-purchaseRecord
# - read-purchaseRecord
# 
# files-related lambdas:
# - move-image
# - archive-image
# - unarchive-image
# - move-pdf
# - archive-pdf
# - unarchive-pdf
# - clear-all-temporary-files
# 
#

module "restful_handler_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "restful_handler_${var.env}"
  description   = "My awesome lambda function (with allowed triggers)"
  #runtime details
  handler       = "index.lambda_handler"
  runtime       = "nodejs18.x"
  #deployment flow
  publish = true
  create_package = false
  source_path = "${path.module}/../code/restful_handler_lambda"
  store_on_s3 = true
  s3_bucket = module.s3_lambda_codedeploy.s3_bucket_id
  s3_prefix   = "lambda-builds/"

  #environment variables and tags
  environment_variables = {
    env=var.env
    region=var.aws_region
  }
  tags = {
    function=local.tag_function_crud
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
  # API trigger
  # allow API
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}

module "error_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  function_name = "error_lambda_${var.env}"
  description   = "My awesome lambda function (with allowed triggers)"
  #runtime details
  handler       = "index.lambda_handler"
  runtime       = "nodejs18.x"
  #deployment flow
  publish = true
  create_package = false
  source_path = "${path.module}/../code/error_lambda"
  store_on_s3 = true
  s3_bucket = module.s3_lambda_codedeploy.s3_bucket_id
  s3_prefix   = "lambda-builds/"

  #environment variables and tags
  environment_variables = {
    env=var.env
    region=var.aws_region
  }
  tags = {
    function=local.tag_function_default
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
  # API trigger
  # allow API
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }
}

module "db_search_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  #descriptive details
  function_name = "db_search_${var.env}"
  description   = "My awesome lambda function (with allowed triggers)"
  #runtime details
  handler       = "index.lambda_handler"
  runtime       = "nodejs18.x"
  #deployment flow
  publish = true
  create_package = false
  source_path = "${path.module}/../code/db_search_lambda"
  store_on_s3 = true
  s3_bucket = module.s3_lambda_codedeploy.s3_bucket_id
  s3_prefix   = "lambda-builds/"

  #environment variables and tags
  environment_variables = {
    env=var.env
    region=var.aws_region
  }
  tags = {
    function=local.tag_function_search
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
  # API trigger
  # allow API
  allowed_triggers = {
    APIGatewaySearch = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/GET/search"
    }
  }
}


module "finalize_testing_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 5.0"

  #descriptive details
  function_name = "finalize_testing_${var.env}"
  description   = "Finalize backend code testing with a step function. Initialize_testing_lambda sets the input for all the lambdas, and finalize_testing_lambda recieve their output and check it."
  #runtime details
  handler       = "index.lambda_handler"
  runtime       = "nodejs18.x"
  #deployment flow
  publish = true
  create_package         = false
  source_path = "${path.module}/../code/finalize_testing_lambda"
  store_on_s3 = true
  s3_bucket = module.s3_lambda_codedeploy.s3_bucket_id
  s3_prefix   = "lambda-builds/"

  #environment variables and tags
  environment_variables = {
    env=var.env
    region=var.aws_region
  }
  tags = {
    function=local.tag_function_default
    system=local.tag_system
    environment=local.tag_environment
    owner=local.tag_owner
    creator=local.tag_creator
  }
  # API trigger
  # Don't allow API
  allowed_triggers = {}
}

#tags
locals{
    tag_function_crud="CRUD-data"
    tag_function_files="files-management"
    tag_function_search="search-data"
    tag_function_move="move-files"
    tag_function_infra="terraform"
    tag_function_default="other"
    tag_system=var.system_name
    tag_environment=var.env
    tag_owner=var.owner_name
    tag_creator=var.creator_name
}