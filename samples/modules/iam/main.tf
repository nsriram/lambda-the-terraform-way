resource "aws_iam_user" "lambda_tf_way_iam_user" {
  name = var.iam_username
}

resource "aws_iam_access_key" "lambda_tf_way_access_key" {
  user = aws_iam_user.lambda_tf_way_iam_user.name
}

resource "aws_iam_policy_attachment" "lambda_tf_way_lambda_policy" {
  name = "lambda-test-user-lambda-policy-attachment"
  users = [aws_iam_user.lambda_tf_way_iam_user.name]
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}
