# Integrate with DynamoDB
This section will provide a walk through on integration between the AWS Lambda and DynamoDb

### DynamoDB
AWS DynamoDB is a fully managed NoSQL Database that provides high performance and scalability. Similar to other services
like Kinesis, S3 etc., DynamoDB also reduces the administrative overhead for teams and lets them focus on building applications.

### A quick overview of DynamoDB
Tables, Items, Attributes, Primary Keys and Indexes form the core concepts for DynamoDB. 
Tables have 2 keys - Partition Key and Sort Key.  Scalar types _(number, string, binary, Boolean, and null)_ are the 
supported types in DynamoDB.  DynamoDB also supports Lists, Maps & Sets that can be persisted in JSON format.
DynamoDB can be configured to publish data change in tables as events. The streams contain the table records.
([Core Concepts Reference](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html))

Unlike SQL, table definitions for creating them are provided in the form of JSON. 
Data is managed (insert, update, delete) as well in the form of JSON. Data is stored in DynamoDB in the 
form of Partitions. Partitions are created dynamically to handle scale. 
([Partitions Reference](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.Partitions.html))

AWS DynamoDB has a lot more features built-in to address large scale system needs.

### Integration Example
AWS Lambda can interact with DynamoDB in 2 ways.
> 1. Synchronous - Like any application accessing NoSQL database, AWS Lambda functions can access DynamoDB to
     query, store, retrieve data from its tables.
> 2. Event Source Mapping - AWS Lambda can listen to events from DynamoDB and process them. For this, 'event streaming'
     can be enabled in DynamoDB tables & an event source mapping similar to our earlier integrations like S3, Kinesis can be
     setup.

This example lambda will focus on the second type
- Listen to DynamoDB Stream Event 
- Logging them on the console.
- View the logs using AWS CloudWatch logs via AWS CLI.

#### (1) Terraform
`main.tf` script (below) in `samples/10/` does the following

- Creates a DynamoDB Table `Orders` (using dynamodb module in `samples/modules/dynamodb`)
- Creates lambda `dynamoDBEventLoggerLambda` that listens to DynamoDB stream events (using lambda module in `module/lambda`)
- Event source mapping between the DynamoDB table and lambda (using module `samples/modules/dynamodb-lambda-event-mapping`)

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  lambda_name = "dynamoDBEventLoggerLambda"
  zip_file_name = "/tmp/dynamoDBEventLoggerLambda.zip"
  handler_name = "dynamoDBEventLoggerLambda.handler"
}

module "lambda_tf_way_orders_table" {
  source = "../modules/dynamodb"
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "dynamodb_event_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "dynamodb_lambda_event_stream_mapping" {
  source = "../modules/dynamodb-lambda-event-mapping"
  lambda_tf_way_function_arn = module.dynamodb_event_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_table_stream_arn = module.lambda_tf_way_orders_table.lambda_tf_way_table_stream_arn
}
```
##### dynamodb module
- dynamodb module at `samples/modules/dynamodb` creates the `Orders` table.
- It has 2 columns 
  - `Id` (Partition Key)
  - `Amount` (Sort Key)
- Event Stream is enabled for `KEYS_ONLY` via the following attributes
  - `stream_enabled`
  - `stream_view_type`
- The read and write capacity are kept minimal at 1 (for tutorial purpose)

> Note: The dynamodb module is not reusable as its values are static configured for `Orders` table only.

##### dynamodb-lambda-event-mapping
- `samples/modules/dynamodb-lambda-event-mapping` module enables the `dynamoDBEventLoggerLambda` to listen to events
from `Orders` table.
- The resource `lambda_tf_way_dynamodb_event_source` in the module's `main.tf` maps the 
event source ARN of the DynamoDB table to the ARN of lambda.

#### (2) Bundle the lambda
This section will refer to the source `samples/10/dynamoDBEventLoggerLambda.js` _(below)_.

##### (2.1) Sample DynamoDB Stream Event
DynamoDB Stream records read by Lambda, have the format mentioned below. Since we enabled only `KEYS_ONLY` as
StreamViewType, the `Records.dynamodb.Keys` will only have the `Keys`. The `dynamoDBEventLoggerLambda` will log these keys.
```json
{
  "Records": [
    {
      "eventID":"123a34bcdefgh56ij7890k12l34567",
      "eventName":"INSERT",
      "eventVersion":"1.0",
      "eventSource":"aws:dynamodb",
      "awsRegion":"us-east-1",
      "dynamodb":{
        "ApproximateCreationDateTime": 1555555511,
        "Keys":{
          "Amount":{
            "N":"1000"
          },
          "Id":{
            "N":"1"
          },
        },
        "SequenceNumber":"123456789012345678901",
        "SizeBytes":12,
        "StreamViewType":"KEYS_ONLY"
      },
      "eventSourceARN":"arn:aws:dynamodb:us-east-1:919191919191:table/Orders/stream/2019-01-01T00:00:00.000"
    }  
  ]
}
```

##### (2.2) Lambda source
This is a simple lambda that will listen to the dynamodb stream and will log the Keys (i.e., PartitionKey and SortKey).
```javascript
exports.handler =  async (event, context, callback) => {
  event.Records.forEach(record => console.log(record.dynamodb.Keys));
};
```

##### (2.3) AWS SDK Dependency
Node module `aws-sdk` is not required explicitly on lambda instances. It is available in the lambda environment by default.

##### (2.4) Bundle the source
Let's bundle the lambda source using the following command (or) the script `bundle-lambda.sh` in `samples/10/`.
Run these commands from `samples/10/` folder.

```shell script
#!/bin/sh
zip /tmp/dynamoDBEventLoggerLambda.zip dynamoDBEventLoggerLambda.js
```

#### (3) Terraform Apply
Now we will run terraform script to create the `dynamoDBEventLoggerLambda`. You need to be in the `samples/10` folder
to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

After terraform apply completes, the output on the console should look similar to the one below.

```shell script
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creating...
module.lambda_tf_way_orders_table.aws_dynamodb_table.lambda_tf_way_orders_table: Creating...
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 2s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.dynamodb_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 2s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.lambda_tf_way_orders_table.aws_dynamodb_table.lambda_tf_way_orders_table: Creation complete after 7s [id=Orders]
module.dynamodb_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [10s elapsed]
module.dynamodb_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [20s elapsed]
module.dynamodb_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 22s [id=dynamoDBEventLoggerLambda]
module.dynamodb_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_dynamodb_event_source: Creating...
module.dynamodb_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_dynamodb_event_source: Creation complete after 0s [id=bd76def1-4786-4d26-99d4-7118eb4e423e]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:dynamoDBEventLoggerLambda"
lambda_name = "dynamoDBEventLoggerLambda"
lambda_tf_way_order_table_arn = "arn:aws:dynamodb:ap-south-1:919191919191:table/Orders"
```

#### (4) Verify DynamoDB event processing

We will trigger `dynamoDBEventLoggerLambda` by putting an item in the `Orders` table. This will send a dynamodb event 
to the lambda via the dynamodb stream. These commands have to be run from the `samples/10` folder (or) you can use the 
`put-item.sh`.

##### (4.1) Put Item
```shell script
#!/bin/sh
aws dynamodb put-item --table-name Orders \
  --item file://newOrder.json \
  --profile "$AWS_PROFILE"
```
##### (4.2) View Log for dynamoDBEventLoggerLambda
We will use AWS CLI and view the logs on AWS Cloud watch to confirm the event processing. For this we need the
LogGroup and LogStream. The latest `LOG_STREAM_NAME` will have the execution details.
> Note: The LOG_STREAM_NAME has `$` symbol and needs to be escaped with backslash.

Fetch the log stream name from the log group. Cloudwatch would have created a log group with name
`/aws/lambda/dynamoDBEventLoggerLambda`. Using that we will get the log stream.

```shell script
aws logs describe-log-streams --log-group-name "/aws/lambda/dynamoDBEventLoggerLambda" --profile "$AWS_PROFILE"
```

> Output: You should get an output similar to the one below.

```json
{
  "logStreams": [
    {
      "logStreamName": "2020/12/28/[$LATEST]0689d153521e462f8b2ea5b7be5fdd4a",
      "creationTime": 1609143050273,
      "firstEventTimestamp": 1609143041142,
      "lastEventTimestamp": 1609143041178,
      "lastIngestionTime": 1609143050280,
      "uploadSequenceToken": "49613940796553278084147692336089911265935507047533559202",
      "arn": "arn:aws:logs:ap-south-1:919191919191:log-group:/aws/lambda/dynamoDBEventLoggerLambda:log-stream:2020/12/28/[$LATEST]0689d153521e462f8b2ea5b7be5fdd4a",
      "storedBytes": 0
    }
  ]
}
```

Now, we will use the log stream `"2020/12/28/[$LATEST]0689d153521e462f8b2ea5b7be5fdd4a"` to see the logs of the lambda
execution.

```shell script
aws logs get-log-events \
  --log-group-name "/aws/lambda/dynamoDBEventLoggerLambda" \
  --log-stream-name "2020/12/28/[\$LATEST]0689d153521e462f8b2ea5b7be5fdd4a"
```

You should see the keys (`{ Amount: { N: '1000' }, Id: { N: '1' } }`) in the log events, similar to the one below.
```json
{
"timestamp": 1609143041145,
"message": "2020-12-28T08:10:41.145Z\tcd92cbe9-9498-475d-8aa2-d5c31876336d\tINFO\t{ Amount: { N: '1000' }, Id: { N: '1' } }\n",
"ingestionTime": 1609143050280
}
```

#### (5) Teardown
Let's run terraform destroy to delete the infra we created in this tutorial, from `samples/10` folder.

```shell script
export AWS_PROFILE=lambda-tf-user
terraform destroy --auto-approve
```

🏁 **Congrats !** You learnt a key integration in serverless - AWS Lambda and Kinesis 🏁

**Next**: [Integrate with SQS](11-integrate-with-sqs.md) 
