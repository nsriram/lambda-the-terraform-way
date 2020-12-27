#!/bin/sh
aws s3api delete-object --key helloworld.txt-metadata.txt --bucket lambda-tf-way-bucket-101 --profile "$AWS_PROFILE"
aws s3api delete-object --key helloworld.txt --bucket lambda-tf-way-bucket-101 --profile "$AWS_PROFILE"