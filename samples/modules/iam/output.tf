output "access_key" {
  value = aws_iam_access_key.lambda_tf_way_access_key.id
}

output "secret" {
  value = aws_iam_access_key.lambda_tf_way_access_key.secret
}
