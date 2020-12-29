resource "aws_api_gateway_rest_api" "lambda_tf_way_rest_api" {
  name = var.lambda_tf_way_rest_api_name
  description = var.lambda_tf_way_rest_api_description
}

resource "aws_api_gateway_method" "lambda_tf_way_api_gateway_get_method" {
  rest_api_id = aws_api_gateway_rest_api.lambda_tf_way_rest_api.id
  resource_id = aws_api_gateway_rest_api.lambda_tf_way_rest_api.root_resource_id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "lambda_tf_way_api_gateway_get_method_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_tf_way_rest_api.id
  resource_id = aws_api_gateway_rest_api.lambda_tf_way_rest_api.root_resource_id
  http_method = aws_api_gateway_method.lambda_tf_way_api_gateway_get_method.http_method
  status_code = "200"
  response_models = {
    "application/json" : "Empty"
  }
}
