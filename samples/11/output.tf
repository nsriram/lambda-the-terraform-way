output "lambda_tf_way_sqs_queue_arn" {
  value = module.lambda_tf_way_sqs_queue.lambda_tf_way_sqs_queue_arn
}

output "lambda_tf_way_sqs_queue_url" {
  value = module.lambda_tf_way_sqs_queue.lambda_tf_way_sqs_queue_url
}

output "lambda_name" {
  value = module.sqs_message_logger_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.sqs_message_logger_lambda.tf_way_lambda_arn
}
