provider "aws" {
  region = var.aws_region
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

locals {
  lambda_name = "formatCurrencyLambda"
  zip_file_name = "/tmp/formatCurrencyLambda.zip"
  handler_name = "formatCurrencyLambda.handler"
}

module "format_currency_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}
