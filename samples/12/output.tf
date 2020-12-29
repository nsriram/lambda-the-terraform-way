output "api_gateway_arn" {
  value = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_arn
}

output "api_gateway_execution_arn" {
  value = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_execution_arn
}

output "stage_invoke_url" {
  value = module.lambda_tf_way_api_gateway_integration.lambda_tf_way_stage_invoke_url
}

output "lambda_name" {
  value = module.current_time_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.current_time_lambda.tf_way_lambda_arn
}
