output "lambda_name" {
  value = module.hello_world_lambda.tf_way_lambda_function_name
}

output lambda_arn {
  value = module.hello_world_lambda.tf_way_lambda_arn
}

output "lambda_role_arn" {
  value = module.lambda_tf_way_role.lambda_role_arn
}
