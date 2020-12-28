provider "aws" {
  region = var.aws_region
}

locals {
  stream_name = "lambda-tf-stream"
  lambda_name = "kinesisEventLoggerLambda"
  zip_file_name = "/tmp/kinesisEventLoggerLambda.zip"
  handler_name = "kinesisEventLoggerLambda.handler"
}

module "lambda_tf_way_kinesis_stream" {
  source = "../modules/kinesis"
  lambda_tf_way_kinesis_stream_name = local.stream_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "kinesis_event_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "kinesis_lambda_event_stream_mapping" {
  source = "../modules/kinesis-lambda-event-mapping"
  lambda_tf_way_function_arn = module.kinesis_event_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_kinesis_stream_arn = module.lambda_tf_way_kinesis_stream.lambda_tf_way_kinesis_stream_arn
}
