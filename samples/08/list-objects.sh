#!/bin/sh
aws s3api list-objects --bucket lambda-tf-way-bucket-101 --profile $AWS_PROFILE
