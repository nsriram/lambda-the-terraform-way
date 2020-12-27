resource "aws_lambda_permission" "lambda_tf_way_s3_permission" {
  principal = "s3.amazonaws.com"
  action = "lambda:InvokeFunction"
  source_arn = var.lambda_tf_way_bucket_arn
  function_name = var.lambda_tf_way_function_arn
}

resource "aws_s3_bucket_notification" "lambda_tf_way_bucket_event" {
  bucket = var.lambda_tf_way_s3_bucket_name
  lambda_function {
    lambda_function_arn = var.lambda_tf_way_function_arn
    events = [
      "s3:ObjectCreated:*"
    ]
  }
}
