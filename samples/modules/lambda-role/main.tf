resource "aws_iam_role" "lambda_tf_way_role" {
  name = "tf_way_lambda_role"
  assume_role_policy = file("${path.module}/lambda-assume-role-policy.json")
}

resource "aws_iam_role_policy" "lambda_tf_way_role_policy" {
  name = "tf_way_lambda_role_policy"
  role = aws_iam_role.lambda_tf_way_role.id
  policy = file("${path.module}/lambda-policy.json")
}