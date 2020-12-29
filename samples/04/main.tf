provider "aws" {
  region = var.aws_region
}

module "lambda_tf_way_user_module" {
  source = "../modules/iam"
  iam_username = "lambda-tf-user"
  pgp_key = "keybase:${var.keybase_id}"
  keybase_id = var.keybase_id
}
