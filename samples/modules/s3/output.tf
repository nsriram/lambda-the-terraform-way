output "lambda_tf_way_bucket_arn" {
  value = aws_s3_bucket.lambda_tf_way_s3_bucket.arn
}

output "lambda_tf_way_bucket_name" {
  value = aws_s3_bucket.lambda_tf_way_s3_bucket.bucket
}