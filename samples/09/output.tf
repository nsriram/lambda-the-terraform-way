output "lambda_tf_way_kinesis_stream_id" {
  value = module.lambda_tf_way_kinesis_stream.lambda_tf_way_kinesis_stream_id
}

output "lambda_tf_way_kinesis_stream_arn" {
  value = module.lambda_tf_way_kinesis_stream.lambda_tf_way_kinesis_stream_arn
}

output "lambda_name" {
  value = module.kinesis_event_logger_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.kinesis_event_logger_lambda.tf_way_lambda_arn
}
