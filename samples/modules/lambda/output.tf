output "tf_way_lambda_arn" {
  value = aws_lambda_function.tf_way_lambda_function.arn
}

output "tf_way_lambda_function_name" {
  value = aws_lambda_function.tf_way_lambda_function.function_name
}
