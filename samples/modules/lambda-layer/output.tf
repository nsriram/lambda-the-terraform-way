output "lambda_tf_way_layer_arn_with_version" {
  value = aws_lambda_layer_version.lambda_tf_way_layer.arn
}

output "lambda_tf_way_layer_version" {
  value = aws_lambda_layer_version.lambda_tf_way_layer.version
}
