#!/bin/sh
aws dynamodb put-item --table-name Orders \
  --item file://newOrder.json \
  --profile "$AWS_PROFILE"