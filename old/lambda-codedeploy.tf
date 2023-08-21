module "restful_handler_lambda_alias_refresh" {
  source = "terraform-aws-modules/lambda/aws/modules/alias"
  refresh_alias = true
  name = "${module.restful_handler_lambda.lambda_function_name}-current-with-refresh"
  function_name = module.restful_handler_lambda.lambda_function_name
  # Set function_version when creating alias to be able to deploy using it,
  # because AWS CodeDeploy doesn't understand $LATEST as CurrentVersion.
  function_version = module.restful_handler_lambda.lambda_function_version
}

module "deploy" {
  source = "../../modules/deploy"

  alias_name    = module.restful_handler_lambda_alias_refresh.lambda_alias_name
  function_name = module.restful_handler_lambda.lambda_function_name

  target_version = module.restful_handler_lambda.lambda_function_version

  create_app = true
  app_name   = "book-inventory"

  create_deployment_group = true
  deployment_group_name   = "lambda_fuctions_${var.env}"

  create_deployment          = true
  run_deployment             = true
  save_deploy_script         = true
  wait_deployment_completion = true
  force_deploy               = true

}
