provider "aws" {
  region = var.aws_region
}

locals {
  bucket_name = "lambda-tf-way-bucket-101"
  lambda_name = "s3ObjectListenerLambda"
  zip_file_name = "/tmp/s3ObjectListenerLambda.zip"
  handler_name = "s3ObjectListenerLambda.handler"
}

module "lambda_tf_way_bucket" {
  source = "../modules/s3"
  lambda_tf_way_s3_bucket = local.bucket_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "s3_object_listener_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "s3_lambda_event_mapping" {
  source = "../modules/s3-lambda-event-mapping"
  lambda_tf_way_bucket_arn = module.lambda_tf_way_bucket.lambda_tf_way_bucket_arn
  lambda_tf_way_s3_bucket_name = module.lambda_tf_way_bucket.lambda_tf_way_bucket_name
  lambda_tf_way_function_arn = module.s3_object_listener_lambda.tf_way_lambda_arn
}
