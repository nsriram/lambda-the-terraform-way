provider "aws" {
  region = var.aws_region
}

locals {
  lambda_name = "helloWorldLambda"
  zip_file_name = "/tmp/helloWorldLambda.zip"
  handler_name = "helloWorldLambda.handler"
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "hello_world_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}