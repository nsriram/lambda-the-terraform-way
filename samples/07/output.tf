output "lambda_name" {
  value = module.current_time_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.current_time_lambda.tf_way_lambda_arn
}

output "lambda_layer_arn_with_version" {
  value = module.moment_js_lambda_layer.lambda_tf_way_layer_arn_with_version
}
