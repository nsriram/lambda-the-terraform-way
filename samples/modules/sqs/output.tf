output "lambda_tf_way_sqs_queue_arn" {
  value = aws_sqs_queue.lambda_tf_way_sqs_queue.arn
}

output "lambda_tf_way_sqs_queue_url" {
  value = aws_sqs_queue.lambda_tf_way_sqs_queue.id
}
