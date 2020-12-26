output "access_key" {
  value = aws_iam_access_key.lambda_tf_way_access_key.id
}

output "secret" {
  value = aws_iam_access_key.lambda_tf_way_access_key.secret
}

output "username" {
  value = aws_iam_user.lambda_tf_way_iam_user.name
}

output "password" {
  value = aws_iam_user_login_profile.lambda-test-user-profile.encrypted_password
}
