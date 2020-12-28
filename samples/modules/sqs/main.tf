resource "aws_sqs_queue" "lambda_tf_way_sqs_queue" {
  name = var.lambda_tf_way_queue_name
}