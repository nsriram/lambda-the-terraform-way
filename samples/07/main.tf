provider "aws" {
  region = var.aws_region
}

locals {
  layer_name = "momentJSLambdaLayer"
  layer_payload = "/tmp/momentJSLambdaLayer.zip"

  lambda_name = "currentTimeLambda"
  zip_file_name = "/tmp/currentTimeLambda.zip"
  handler_name = "currentTimeLambda.handler"
}

module "moment_js_lambda_layer" {
  source = "../modules/lambda-layer"
  lambda_layer_name = local.layer_name
  lambda_layer_payload = local.layer_payload
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "current_time_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
  lambda_tf_way_layer = module.moment_js_lambda_layer.lambda_tf_way_layer_arn_with_version
}
