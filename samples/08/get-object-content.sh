#!/bin/sh
aws s3api get-object --bucket lambda-tf-way-bucket-101 --key helloworld.txt-metadata.txt helloworld.txt-metadata.txt
cat helloworld.txt-metadata.txt