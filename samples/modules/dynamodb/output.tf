output "lambda_tf_way_table_stream_arn" {
  value = aws_dynamodb_table.lambda_tf_way_orders_table.stream_arn
}

output "lambda_tf_way_table_arn" {
  value = aws_dynamodb_table.lambda_tf_way_orders_table.arn
}
