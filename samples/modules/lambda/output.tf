output "tf_way_lambda_arn" {
  value = aws_lambda_function.lambda_tf_way_function.arn
}

output "tf_way_lambda_invoke_arn" {
  value = aws_lambda_function.lambda_tf_way_function.invoke_arn
}

output "tf_way_lambda_function_name" {
  value = aws_lambda_function.lambda_tf_way_function.function_name
}


