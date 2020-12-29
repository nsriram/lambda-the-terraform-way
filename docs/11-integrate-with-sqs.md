# Integrate with SQS
This section will provide a walk through on integration between the AWS Lambda and SQS

### SQS
Simple Queue Service (SQS) is a fully manages message queueing service from AWS. It provides high-throughput system to
system messaging & is highly scalable

### A quick overview of SQS
SQS is based on topics and doesn't require a message broker to be configured. SQS provides 2 types of queues.
1. Standard Queue (has unlimited throughput)
2. FIFO Queue (maintains the order)

Producers can send messages to an SQS queue. These messages are distributed across SQS servers for redundancy. Messages
can be configured for a certain timeout. SQS can be configured to trigger Lambda functions, similar to Kinesis & DynamoDB.
Key benefits of using SQS are
- Security
- Durability
- Availability
- Scalability
- Reliability

[Reference here](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)

### Integration Example
Lambda for this example will 
- Consume messages published to an SQS Queue 
- Log them on the console
- View the logs using AWS CloudWatch logs via AWS CLI.

#### (1) Terraform

`main.tf` script (below) in `samples/11/` does the following

- Creates a SQS Queue `LambdaTFQueue` (using sqs module in `samples/modules/sqs`)
- Creates lambda `sqsMessageLoggerLambda` that listens to SQS Messages (using lambda module in `module/lambda`)
- Event source mapping between the SQS Queue and lambda (using module `samples/modules/sqs-lambda-event-mapping`)

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  queue_name = "LambdaTFQueue"
  lambda_name = "sqsMessageLoggerLambda"
  zip_file_name = "/tmp/sqsMessageLoggerLambda.zip"
  handler_name = "sqsMessageLoggerLambda.handler"
}
module lambda_tf_way_sqs_queue {
  source = "../modules/sqs"
  lambda_tf_way_queue_name = local.queue_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "sqs_message_logger_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "sqs_lambda_event_stream_mapping" {
  source = "../modules/sqs-lambda-event-mapping"
  lambda_tf_way_function_arn = module.sqs_message_logger_lambda.tf_way_lambda_arn
  lambda_tf_way_sqs_queue_arn = module.lambda_tf_way_sqs_queue.lambda_tf_way_sqs_queue_arn
}
```

##### sqs module
- sqs module at `samples/modules/sqs` creates the `LambdaTFQueue` queue.
- It is a standard Queue

##### sqs-lambda-event-mapping
- `samples/modules/sqs-lambda-event-mapping` module enables the `sqsMessageLoggerLambda` to listen to messages 
  from `LambdaTFQueue` queue.
- Resource definition `lambda_tf_way_sqs_event_source_mapping` in the module's `main.tf` maps the
  event source ARN of the SQS to the ARN of lambda.

#### (2) Bundle the lambda
This section will refer to the source `samples/11/sqsMessageLoggerLambda.js` _(below)_.

##### (2.1) Sample SQS Message Event
Following is a sample message event Lambda receives after polling the SQS Queue.

```javascript
{
  Records: [
    {
      messageId: 'd7bb9cb2-9f5d-4f28-8390-015f22ff1528',
      receiptHandle: 'aBcDEeFG1H2IjKlM3nOPQrS4Tuv5W6xYZaB+7CdEf8g=',
      body: 'Hello World',
      attributes: {
        ApproximateReceiveCount: '1',
        SentTimestamp: '1609214372653',
        SenderId: 'ABCDEABCDEABCDEABCDEA',
        ApproximateFirstReceiveTimestamp: '1609214372656'
      },
      messageAttributes: {},
      md5OfBody: '793a5a5351059f4ab11d48ad79878716',
      eventSource: 'aws:sqs',
      eventSourceARN: 'arn:aws:sqs:ap-south-1:919191919191:LambdaTFQueue',
      awsRegion: 'ap-south-1'
    }
  ]
}
```

##### (2.2) Lambda source
This is a simple lambda that will listen to the SQS message stream and will log the Keys (i.e., PartitionKey and SortKey).
```javascript
exports.handler =  async (event) => {
  event.Records.forEach(record => console.log(record.body));
};
```

##### (2.3) AWS SDK Dependency
Node module `aws-sdk` is not required explicitly on lambda instances. It is available in the lambda environment by default.

##### (2.4) Bundle the source
Let's bundle the lambda source using the following command (or) the script `bundle-lambda.sh` in `samples/11/`.
Run these commands from `samples/11/` folder.
```shell script
#!/bin/sh
zip /tmp/sqsMessageLoggerLambda.zip sqsMessageLoggerLambda.js
```

#### (3) Terraform Apply
Now we will run terraform script to create the `sqsMessageLoggerLambda`. You need to be in the `samples/11` folder
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
module.lambda_tf_way_sqs_queue.aws_sqs_queue.lambda_tf_way_sqs_queue: Creating...
module.lambda_tf_way_sqs_queue.aws_sqs_queue.lambda_tf_way_sqs_queue: Creation complete after 0s [id=https://sqs.ap-south-1.amazonaws.com/919191919191/LambdaTFQueue]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 2s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.sqs_message_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 3s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.sqs_message_logger_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [10s elapsed]
module.sqs_message_logger_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [20s elapsed]
module.sqs_message_logger_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 23s [id=sqsMessageLoggerLambda]
module.sqs_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_sqs_event_source_mapping: Creating...
module.sqs_lambda_event_stream_mapping.aws_lambda_event_source_mapping.lambda_tf_way_sqs_event_source_mapping: Creation complete after 0s [id=9d5779ec-b7c8-4599-943f-7777d2a5f85d]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:sqsMessageLoggerLambda"
lambda_name = "sqsMessageLoggerLambda"
lambda_tf_way_sqs_queue_arn = "arn:aws:sqs:ap-south-1:919191919191:LambdaTFQueue"
lambda_tf_way_sqs_queue_url = "https://sqs.ap-south-1.amazonaws.com/919191919191/LambdaTFQueue"
```

#### (4) Verify SQS message event processing

We will trigger `sqsMessageLoggerLambda` by sending a message to the `LambdaTFQueue`. This will result in an event
via the SQS stream to the lambda. These commands have to be run from the `samples/11` folder.

>Note: You have to change the AWS Account Id from `919191919191` to your actual value.

##### (4.1) Send Message

```shell script
#!/bin/sh
aws sqs send-message --queue-url https://sqs.ap-south-1.amazonaws.com/919191919191/LambdaTFQueue --message-body "Hello World"
```
> Output : Sending a message to the Queue should produce an output as below
```json
{
  "MD5OfMessageBody": "b10a8db164e0754105b7a99be72e3fe5",
  "MessageId": "87443045-8be2-412e-85f1-6729480c3971"
}
```

##### (4.2) View Log for sqsMessageLoggerLambda
We will use AWS CLI and view the logs on AWS Cloud watch to confirm the event processing. For this we need the
LogGroup and LogStream. The latest `LOG_STREAM_NAME` will have the execution details.

Fetch the log stream name from the log group. Cloudwatch would have created a log group with name
`/aws/lambda/sqsMessageLoggerLambda`. Using that we will get the log stream.

```shell script
aws logs describe-log-streams --log-group-name "/aws/lambda/sqsMessageLoggerLambda" --profile "$AWS_PROFILE"
```
> Output: You should get an output similar to the one below.
```json
{
    "logStreams": [
        {
            "logStreamName": "2020/12/28/[$LATEST]04719391cb2b4156ab2c8bb321576d27",
            "creationTime": 1609147973417,
            "firstEventTimestamp": 1609147964223,
            "lastEventTimestamp": 1609148001417,
            "lastIngestionTime": 1609148010424,
            "uploadSequenceToken": "49613012195329571630084228965924883273361721093276075698",
            "arn": "arn:aws:logs:ap-south-1:919191919191:log-group:/aws/lambda/sqsMessageLoggerLambda:log-stream:2020/12/28/[$LATEST]04719391cb2b4156ab2c8bb321576d27",
            "storedBytes": 0
        }
    ]
}
```

Now, we will use the log stream `"2020/12/28/[$LATEST]04719391cb2b4156ab2c8bb321576d27"` to see the logs of the lambda
execution.

> Note: The LOG_STREAM_NAME has `$` symbol and needs to be escaped with backslash.

```shell script
aws logs get-log-events \
  --log-group-name "/aws/lambda/sqsMessageLoggerLambda" \
  --log-stream-name "2020/12/28/[\$LATEST]04719391cb2b4156ab2c8bb321576d27"
```

You should see the `Hello World` message in the log events, similar to the one below.

```json
{
  "timestamp": 1609147964225,
  "message": "2020-12-28T09:32:44.224Z\tfd4343a6-71f1-5065-9058-1bc5d98279c4\tINFO\tHello World\n",
  "ingestionTime": 1609147973423
}
```

#### (5) Teardown
Let's run terraform destroy to delete the infra we created in this tutorial, from `samples/11` folder.

```shell script
export AWS_PROFILE=lambda-tf-user
terraform destroy --auto-approve
```

🏁 **Congrats !** You learnt a key integration in serverless - AWS Lambda and SQS 🏁

**Next**: [Integrate with APIGateway](12-integrate-with-api-gateway.md)