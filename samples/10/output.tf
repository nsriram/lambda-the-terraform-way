output "lambda_tf_way_order_table_arn" {
  value = module.lambda_tf_way_orders_table.lambda_tf_way_table_arn
}

output "lambda_name" {
  value = module.dynamodb_event_logger_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.dynamodb_event_logger_lambda.tf_way_lambda_arn
}
