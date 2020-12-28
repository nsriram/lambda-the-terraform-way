# Integrate with Kinesis
This section will walk through integration between 2 AWS services - Kinesis and Lambda.

### Kinesis
Kinesis is a large scale, realtime event stream processing service from AWS. Kinesis is fully managed by AWS and
offers less infrastructure maintenance to users. Kinesis can handle large scale streaming data at low latency.
Various sources can publish events to Kinesis and multiple consumers can connect and process the events.

#### Integration Example
AWS Lambda can be one of the consumers to process the records in Kinesis. AWS Lambda service can poll the Kinesis
stream for the records and invoke a particular lambda function for processing.

The lambda function for this integration example will log the event received from kinesis. The log can be viewed using
AWS cloud watch. The `tf_way_lambda_role` we created will be used here too.

#### (1) Terraform
`main.tf` script (below) in `samples/09/` does the following
- Creates a Kinesis stream `lambda-tf-stream` (using kinesis module in `samples/modules/kinesis`)
- Creates lambda `kinesisEventLoggerLambda` that listens to Kinesis stream events (using lambda module in folder `module/lambda`)
- Event source mapping between the Kinesis stream and lambda (using module `samples/modules/s3-lambda-event-mapping`)

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  stream_name = "lambda-tf-stream"
  lambda_name = "kinesisEventLoggerLambda"
  zip_file_name = "/tmp/kinesisEventLoggerLambda.zip"
  handler_name = "kinesisEventLoggerLambda.handler"
}

module "lambda_tf_way_kinesis_stream" {
  source = "../modules/kinesis"
  lambda_tf_way_kinesis_stream_name = local.stream_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "kinesis_event_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "kinesis_lambda_event_stream_mapping" {
  source = "../modules/kinesis-lambda-event-mapping"
  lambda_tf_way_function_arn = module.kinesis_event_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_kinesis_stream_arn = module.lambda_tf_way_kinesis_stream.lambda_tf_way_kinesis_stream_arn
}
```
##### kinesis-lambda-event-mapping module
- `samples/modules/kinesis-lambda-event-mapping` module enables the `kinesisEventLoggerLambda` to listen to events 
  from `lambda-tf-stream`. 
- The resource `lambda_tf_way_kinesis_event_source_mapping` in the module's `main.tf` maps the event source ARN 
  of the kinesis stream to the ARN of lambda. 

#### (2) Bundle the lambda
This section will refer to the source `samples/09/kinesisEventLoggerLambda.js` _(below)_.

##### (2.1) Sample Kinesis Record Event
Stream records read from Kinesis processed by Lambda, will have the following format.
```json
{
  "Records": [
    {
      "kinesis": {
        "kinesisSchemaVersion": "1.0",
        "partitionKey": "",
        "sequenceNumber": "",
        "data": "",
        "approximateArrivalTimestamp": 
      },
      "eventSource": "aws:kinesis",
      "eventVersion": "1.0",
      "eventID": "shardId-000000000001:",
      "eventName": "aws:kinesis:record",
      "invokeIdentityArn": "arn:aws:iam::919191919191:role/tf_way_lambda_role",
      "awsRegion": "ap-south-1",
      "eventSourceARN": "arn:aws:kinesis:us-east-1:123456789012:stream/lambda-tf-stream"
    }
  ]
}
```

##### (2.2) Lambda source
This is a simple lambda that will listen to the kinesis stream and will log the event payload.

```javascript
exports.handler = async (event) => {
  console.log(JSON.stringify(event));
  event.Records.forEach(record => {
    const eventPayload = Buffer.from(record.kinesis.data, 'base64')
      .toString('utf8');
    console.log(eventPayload);
  });
};
```
##### (2.3) AWS SDK Dependency
Node module `aws-sdk` is not required explicitly on lambda instances. It is available in the lambda environment by default.

##### (2.4) Bundle the source
Let's bundle the lambda source using the following command (or) the script `bundle-lambda.sh` in `samples/09/`. 
Run these commands from `samples/09/` folder.

```shell script
#!/bin/sh
zip /tmp/kinesisEventLoggerLambda.zip kinesisEventLoggerLambda.js
```
#### (3) Terraform Apply
Now we will run terraform script to create the `kinesisEventLoggerLambda`. You need to be in the `samples/09` folder 
to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

After terraform apply completes, the output on the console should look similar to the one below.

```shell script
module.lambda_tf_way_kinesis_stream.aws_kinesis_stream.lambda_tf_way_kinesis_stream: Creating...
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creating...
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 3s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.kinesis_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 2s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.lambda_tf_way_kinesis_stream.aws_kinesis_stream.lambda_tf_way_kinesis_stream: Still creating... [10s elapsed]
module.kinesis_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [10s elapsed]
module.kinesis_event_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 13s [id=kinesisEventLoggerLambda]
module.lambda_tf_way_kinesis_stream.aws_kinesis_stream.lambda_tf_way_kinesis_stream: Still creating... [20s elapsed]
module.lambda_tf_way_kinesis_stream.aws_kinesis_stream.lambda_tf_way_kinesis_stream: Still creating... [30s elapsed]
module.lambda_tf_way_kinesis_stream.aws_kinesis_stream.lambda_tf_way_kinesis_stream: Creation complete after 31s [id=arn:aws:kinesis:ap-south-1:919191919191:stream/lambda-tf-stream]
module.kinesis_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_kinesis_event_source_mapping: Creating...
module.kinesis_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_kinesis_event_source_mapping: Creation complete after 1s [id=fac6a05c-974c-4f4e-b8c7-d6fb9a132056]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:kinesisEventLoggerLambda"
lambda_name = "kinesisEventLoggerLambda"
lambda_tf_way_kinesis_stream_arn = "arn:aws:kinesis:ap-south-1:919191919191:stream/lambda-tf-stream"
lambda_tf_way_kinesis_stream_id = "arn:aws:kinesis:ap-south-1:919191919191:stream/lambda-tf-stream"
```

#### (4) Verify kinesis event processing

Let's publish an event in the `lambda-tf-stream`. The event will be processed by `kinesisEventLoggerLambda` and 
we can check it in CloudWatch logs. These commands have to be run from the `samples/09` folder. 

##### (4.1) Publish event
We will publish the event with a message (data) using AWS CLI.

```shell script
aws kinesis put-record --stream-name lambda-tf-stream \
    --partition-key 1 \
    --cli-binary-format raw-in-base64-out \
    --data "{\"message\":\"Hello World\"}" \
    --profile "$AWS_PROFILE"
```

> Output:
```json
{
    "ShardId": "shardId-000000000000",
    "SequenceNumber": "12345678901234567890123456789012345678901234567890123456"
}
```

##### (4.2) View Lambda Log for kinesisEventLoggerLambda
We will use AWS CLI and view the logs on AWS Cloud watch to confirm the event processing. For this we need the
LogGroup and LogStream.

Fetch the log stream name from the log group. Cloudwatch would have created a log group with name 
`/aws/lambda/kinesisEventLoggerLambda`. Using that we will get the log stream.

```shell script
aws logs describe-log-streams --log-group-name "/aws/lambda/kinesisEventLoggerLambda" --profile "$AWS_PROFILE"
```
> Output:
```json
{
    "logStreams": [
        {
            "logStreamName": "2020/12/28/[$LATEST]76578ac49cda4fe7880a1736caf4647c",
            "creationTime": 1609127483718,
            "firstEventTimestamp": 1609127474532,
            "lastEventTimestamp": 1609127474548,
            "lastIngestionTime": 1609127483725,
            "uploadSequenceToken": "49613849064378068760701301231625160132976062756697442642",
            "arn": "arn:aws:logs:ap-south-1:919191919191:log-group:/aws/lambda/kinesisEventLoggerLambda:log-stream:2020/12/28/[$LATEST]76578ac49cda4fe7880a1736caf4647c",
            "storedBytes": 0
        }
    ]
}
```

Now, we will use the log stream `"2020/12/28/[$LATEST]76578ac49cda4fe7880a1736caf4647c"` to see the logs of the lambda
execution.

```shell script
aws logs get-log-events \
  --log-group-name "/aws/lambda/kinesisEventLoggerLambda" \
  --log-stream-name "2020/12/28/[\$LATEST]76578ac49cda4fe7880a1736caf4647c"
```

You should see a message (Hello World) in the log events, similar to the one below.

```json
{
    "timestamp": 1609127474547,
    "message": "2020-12-28T03:51:14.547Z\tfe3d11a7-7f6a-4017-b40d-03cb0dfa73e0\tINFO\t{\"message\":\"Hello World\"}\n",
    "ingestionTime": 1609127483725
}
```

#### (5) Teardown
Let's run terraform destroy to delete the infra we created in this tutorial.

```shell script
export AWS_PROFILE=lambda-tf-user
terraform destroy --auto-approve
```

🏁 **Congrats !** You learnt a key integration in serverless - AWS Lambda and Kinesis 🏁

**Next**: [Integrate with DynamoDB](10-integrate-with-dynamodb.md) 