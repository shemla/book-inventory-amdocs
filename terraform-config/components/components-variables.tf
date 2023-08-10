variable "aws_region"{
    description = ""
    type = string
    default = "us-east-1"
}
# ACM vars
variable "domain_name" {
    description = ""
    type = string
    default = "bookteam.net"
}

# API Gateway
variable "restful_handler_lambda_arn" {
    description = "The Lambda arn of restful-handler"
    type = string
    default = ""#TODO
}
variable "db_search_lambda_arn" {
    description = "The Lambda arn of db-search"
    type = string
    default = ""#TODO
}
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

# Cognito
variable "response_email" {
  description = "email address that sends signup-related messages"
  type = string
  default = "ori.a.shemla@gmail.com"
}

