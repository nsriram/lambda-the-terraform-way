resource "aws_dynamodb_table" "lambda_tf_way_orders_table" {
  name = "Orders"
  hash_key = "Id"
  range_key = "Amount"
  attribute {
    name = "Id"
    type = "N"
  }
  attribute {
    name = "Amount"
    type = "N"
  }
  billing_mode   = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1
  stream_enabled = true
  stream_view_type = "KEYS_ONLY"
}
