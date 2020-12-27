#!/bin/sh
echo "Hello Lambda Terraform world" > helloworld.txt
aws s3api put-object --bucket lambda-tf-way-bucket-101 --key helloworld.txt --body helloworld.txt --profile "$AWS_PROFILE"
