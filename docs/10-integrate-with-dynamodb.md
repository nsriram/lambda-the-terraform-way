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

Our example will focus on the second type, listening to DynamoDB Stream Event and logging them on the console.
We can view the logs using AWS CloudWatch logs.
 
