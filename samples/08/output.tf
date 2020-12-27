output "lambda_tf_way_s3_bucket_name" {
  value = module.lambda_tf_way_bucket.lambda_tf_way_bucket_name
}

output "lambda_tf_way_s3_bucket_arn" {
  value = module.lambda_tf_way_bucket.lambda_tf_way_bucket_arn
}

output "lambda_name" {
  value = module.s3_object_listener_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.s3_object_listener_lambda.tf_way_lambda_arn
}
