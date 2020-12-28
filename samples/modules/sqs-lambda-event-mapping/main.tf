resource "aws_lambda_event_source_mapping" "lambda_tf_way_sqs_event_source_mapping" {
  function_name = var.lambda_tf_way_function_arn
  event_source_arn = var.lambda_tf_way_sqs_queue_arn
  batch_size = 1
}