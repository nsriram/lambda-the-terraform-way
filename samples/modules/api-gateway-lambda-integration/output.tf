output "lambda_tf_way_stage_invoke_url" {
  value = aws_api_gateway_deployment.lambda_tf_way_rest_api_deployment.invoke_url
}