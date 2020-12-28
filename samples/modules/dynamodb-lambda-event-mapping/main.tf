resource "aws_lambda_event_source_mapping" "lambda_tf_way_dynamodb_event_source" {
  event_source_arn  = var.lambda_tf_way_table_stream_arn
  function_name     = var.lambda_tf_way_function_arn
  starting_position = "LATEST"
  batch_size = 1
}