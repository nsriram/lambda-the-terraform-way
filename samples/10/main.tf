provider "aws" {
  region = var.aws_region
}

locals {
  lambda_name = "dynamoDBEventLoggerLambda"
  zip_file_name = "/tmp/dynamoDBEventLoggerLambda.zip"
  handler_name = "dynamoDBEventLoggerLambda.handler"
}

module "lambda_tf_way_orders_table" {
  source = "../modules/dynamodb"
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "dynamodb_event_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "dynamodb_lambda_event_stream_mapping" {
  source = "../modules/dynamodb-lambda-event-mapping"
  lambda_tf_way_function_arn = module.dynamodb_event_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_table_stream_arn = module.lambda_tf_way_orders_table.lambda_tf_way_table_stream_arn
}
