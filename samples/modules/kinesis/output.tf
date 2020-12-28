output "lambda_tf_way_kinesis_stream_arn" {
  value = aws_kinesis_stream.lambda_tf_way_kinesis_stream.arn
}

output "lambda_tf_way_kinesis_stream_id" {
  value = aws_kinesis_stream.lambda_tf_way_kinesis_stream.id
}
