provider "aws" {
  region = var.aws_region
}

locals {
  queue_name = "LambdaTFQueue"
  lambda_name = "sqsMessageLoggerLambda"
  zip_file_name = "/tmp/sqsMessageLoggerLambda.zip"
  handler_name = "sqsMessageLoggerLambda.handler"
}
module lambda_tf_way_sqs_queue {
  source = "../modules/sqs"
  lambda_tf_way_queue_name = local.queue_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "sqs_message_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "sqs_lambda_event_stream_mapping" {
  source = "../modules/sqs-lambda-event-mapping"
  lambda_tf_way_function_arn = module.sqs_message_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_sqs_queue_arn = module.lambda_tf_way_sqs_queue.lambda_tf_way_sqs_queue_arn
}