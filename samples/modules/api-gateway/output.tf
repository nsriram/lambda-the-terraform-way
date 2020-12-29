output "lambda_tf_way_rest_api_id" {
  value = aws_api_gateway_rest_api.lambda_tf_way_rest_api.id
}

output "lambda_tf_way_rest_api_root_resource_id" {
  value = aws_api_gateway_rest_api.lambda_tf_way_rest_api.root_resource_id
}

output "lambda_tf_way_rest_api_method" {
  value = aws_api_gateway_method.lambda_tf_way_api_gateway_get_method.http_method
}

output "lambda_tf_way_rest_api_method_response_status_code" {
  value = aws_api_gateway_method_response.lambda_tf_way_api_gateway_get_method_response.status_code
}

output "lambda_tf_way_rest_api_arn" {
  value = aws_api_gateway_rest_api.lambda_tf_way_rest_api.arn
}

output "lambda_tf_way_rest_api_execution_arn" {
  value = aws_api_gateway_rest_api.lambda_tf_way_rest_api.execution_arn
}
