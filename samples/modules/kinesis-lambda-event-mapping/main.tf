resource "aws_lambda_event_source_mapping" "lambda_tf_way_kinesis_event_source_mapping" {
  event_source_arn  = var.lambda_tf_way_kinesis_stream_arn
  function_name     = var.lambda_tf_way_function_arn
  batch_size = 1
  starting_position = "LATEST"
}
