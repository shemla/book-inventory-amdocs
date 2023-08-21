# In this file:
# certificates manager (ACM) certificate arn
# API Gateways with 3-4 integrations
# Application load balancer
# Network load balancer

data "aws_route53_zone" "this" {
  name = var.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.domain_name
  zone_id      = data.aws_route53_zone.this.id
  wait_for_validation = true
}

 

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.2"

  name          = "apigw-http-book-inventory"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Custom domain
  domain_name                 = var.domain_name
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  # Routes and integrations
  integrations = {
    "ANY /" = {
      lambda_arn             = module.restful_handler_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 20000
      authorizer_key         = "cognito"
    }
    
    "GET /search" = {
      lambda_arn             = module.db_search_lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 20000
      authorizer_key         = "cognito"
    }
    
    "POST /files" = {
      integration_type = "HTTP_PROXY"
      integration_uri  = module.s3_bucket_temp_files.s3_bucket_arn
      authorizer_key   = "cognito"
    }
    
    "GET /files" = {
      integration_type = "HTTP_PROXY"
      integration_uri  = module.s3_bucket_files.s3_bucket_arn
      authorizer_key   = "cognito"
    }

    "$default" = {
      lambda_arn = module.error_lambda.lambda_function_arn
    }
  }

  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = "$request.header.Authorization"
      name             = "cognito"
      issuer           = "https://${module.aws_cognito_user_pool_complete.endpoint}"
    }
  }

}
# TODO: Define then load balancer to target the API Gateway
# ALB
#module "alb" {
#    source  = "terraform-aws-modules/alb/aws"
#  version = "~> 8.0"
#
#  name = "restful_alb"
#
#  load_balancer_type = "application"
#  #domain_name = "bookteam.net"
#  
#  #todo: add vpc details
#
#  https_listeners = [
#    {
#      port               = 443
#      protocol           = "HTTPS"
#      certificate_arn    = module.acm.acm_certificate_arn
#      target_group_index = 0
#    }
#  ]
#  
#  target_groups = [{
#    name_prefix                        = "l1-"
#    target_type                        = "lambda"
#    lambda_multi_value_headers_enabled = true
#    targets = {
#        restful_handler_lambda = {
#            target_id = module.restful_handler_lambda.lambda_function_arn
#        }
#    }
#  }]
#}
#
