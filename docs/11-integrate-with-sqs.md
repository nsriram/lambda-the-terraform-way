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
can be configured for a certain timeout.

SQS can be configured to trigger Lambda functions, similar to Kinesis & DynamoDB.

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