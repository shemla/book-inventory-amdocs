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
  #integrations = {
  #  "GET /" = {
  #    lambda_arn             = "arn:aws:lambda:eu-west-1:052235179155:function:my-function"
  #    payload_format_version = "2.0"
  #    timeout_milliseconds   = 12000
  #  }
  #
  #  "POST /book-image" = {
  #    integration_type = "HTTP_PROXY"
  #    integration_uri  = "some url"
  #    authorizer_key   = "cognito"
  #  }
  #
  #  "$default" = {
  #    lambda_arn = "arn:aws:lambda:eu-west-1:052235179155:function:my-default-function"
  #  }
  #}

  authorizers = {
    "cognito" = {
      authorizer_type  = "JWT"
      identity_sources = "$request.header.Authorization"
      name             = "cognito"
      issuer           = "https://${module.aws_cognito_user_pool_complete.endpoint}"
    }
  }

}

# ALB
module "alb" {
    source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-alb"

  load_balancer_type = "application"
  domain_name = "bookteam.net"
  
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]
  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  
}