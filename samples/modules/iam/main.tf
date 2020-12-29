resource "aws_iam_user" "lambda_tf_way_iam_user" {
  name = var.iam_username
}

resource "aws_iam_access_key" "lambda_tf_way_access_key" {
  user = aws_iam_user.lambda_tf_way_iam_user.name
}

resource "aws_iam_user_login_profile" "lambda-test-user-profile" {
  user    = aws_iam_user.lambda_tf_way_iam_user.name
  pgp_key = var.pgp_key
  password_reset_required = false
}

resource "aws_iam_policy_attachment" "lambda_tf_way_lambda_policy" {
  name = "lambda-test-user-lambda-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_iam_policy" {
  name = "lambda-test-user-iam-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_s3_policy" {
  name = "lambda-test-user-s3-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_kinesis_policy" {
  name = "lambda-test-user-kinesis-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_dynamodb_policy" {
  name = "lambda-test-user-dynamodb-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_sqs_policy" {
  name = "lambda-test-user-sqs-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_policy_attachment" "lambda_tf_way_api_gateway_policy" {
  name = "lambda-test-user-api-gateway-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
