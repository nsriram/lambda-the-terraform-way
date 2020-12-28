resource "aws_kinesis_stream" "lambda_tf_way_kinesis_stream" {
  name = var.lambda_tf_way_kinesis_stream_name
  shard_count = 1
}
