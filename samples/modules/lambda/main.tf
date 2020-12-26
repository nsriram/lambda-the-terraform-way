resource "aws_lambda_function" "tf_way_lambda_function" {
  filename = var.lambda_zip_filename
  function_name = var.lambda_function_name
  handler = var.lambda_function_handler
  role = var.lambda_role_arn
  runtime = "nodejs12.x"
}