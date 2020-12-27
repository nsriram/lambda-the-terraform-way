resource "aws_lambda_layer_version" "lambda_tf_way_layer" {
  filename   = var.lambda_layer_payload
  layer_name = var.lambda_layer_name
  source_code_hash = filebase64sha256(var.lambda_layer_payload)
  compatible_runtimes = ["nodejs12.x"]
}
