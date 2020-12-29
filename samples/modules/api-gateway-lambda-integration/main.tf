resource "aws_api_gateway_integration" "lambda_tf_way_api_gateway_lambda_get_integration" {
  rest_api_id = var.lambda_tf_way_rest_api_id
  resource_id = var.lambda_tf_way_resource_id
  http_method = var.lambda_tf_way_method
  type = "AWS"
  integration_http_method = "POST"
  uri = var.lambda_tf_way_lambda_invoke_arn
}

resource "aws_api_gateway_integration_response" "lambda_tf_way_api_gateway_lambda_get_integration_response" {
  rest_api_id = aws_api_gateway_integration.lambda_tf_way_api_gateway_lambda_get_integration.rest_api_id
  resource_id = aws_api_gateway_integration.lambda_tf_way_api_gateway_lambda_get_integration.resource_id
  http_method = aws_api_gateway_integration.lambda_tf_way_api_gateway_lambda_get_integration.http_method
  status_code = var.lambda_tf_way_method_response_status_code
  response_templates = {
    "application/json" : ""
  }
}

resource "aws_api_gateway_deployment" "lambda_tf_way_rest_api_deployment" {
  rest_api_id = aws_api_gateway_integration_response.lambda_tf_way_api_gateway_lambda_get_integration_response.rest_api_id
  stage_name = "prod"
}

resource "aws_lambda_permission" "lambda_tf_way_api_gateway_permission" {
  statement_id  = "AllowLambdaExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_tf_way_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${var.lambda_tf_way_rest_api_execution_arn}/*/GET/"
}
