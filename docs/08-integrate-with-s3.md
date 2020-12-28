# Integrate with S3
This section explains how integration can be achieved between the 2 AWS services - Lambda and S3.

### Events and Async Systems
Events can be produced by various AWS services (e.g., S3) for certain actions. Events allow systems to be designed
for asynchronous architectures. Asynchronous architectures allow systems to scale better and events are used as a
medium of connecting various AWS Services.

> Note: Certain AWS Services (ELB, API Gateway, Lex, Alexa etc.,) can also invoke AWS Lambda synchronously.

### AWS S3
AWS S3 (Simple Storage Service) is an object storage service that is highly scalable and available. Objects of varying
size can be stored in buckets. AWS Lambda can be integrated with S3, and S3 can invoke a lambda with events
around the s3-object lifecycle. The list of S3 event types supported are available here - 
[S3 Event Types](https://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html#supported-notification-event-types).

There are many realtime use-cases where S3 object lifecycle events will need further processing,
starting from
* uploading an image to s3 should be followed by the creation of its thumbnail,
* uploading a document to s3 should be followed by its indexing
* deletion of a document should notify some related individual
* more examples .,

#### Integration Example
The lambda function for this example 
- Will listen for S3 object create events (in a S3 bucket). 
- Will upload a metadata *file* after processing the event. 
- The metadata file will contain information about the source object (that was uploaded).   

#### (1) Terraform 
`main.tf` script in `samples/08/` folder does the following
- Creates S3 bucket `lambda-tf-way-bucket-101` (S3 module in folder `module/s3`)
- Creates lambda `s3ObjectListenerLambda` that listens to s3 object create events (using lambda module in folder `module/lambda`)
- Event source mapping between the S3 bucket and lambda (using module `sample/modules/kinesis-lambda-event-mapping`)

> Note: One of the constraints of S3 is, bucket names have to be universally unique. 
Hence, giving a universally unique name to the bucket is important. You can change the bucket name from
`lambda-tf-way-bucket-101` to any other name.

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  bucket_name = "lambda-tf-way-bucket-101"
  lambda_name = "s3ObjectListenerLambda"
  zip_file_name = "/tmp/s3ObjectListenerLambda.zip"
  handler_name = "s3ObjectListenerLambda.handler"
}

module "lambda_tf_way_bucket" {
  source = "../modules/s3"
  lambda_tf_way_s3_bucket = bucket_name
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "s3_object_listener_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}

module "s3_lambda_event_mapping" {
  source = "../modules/s3-lambda-event-mapping"
  lambda_tf_way_bucket_arn = module.lambda_tf_way_bucket.lambda_tf_way_bucket_arn
  lambda_tf_way_s3_bucket_name = module.lambda_tf_way_bucket.lambda_tf_way_bucket_name
  lambda_tf_way_function_arn = module.s3_object_listener_lambda.tf_way_lambda_arn
}
```

##### s3-lambda-event-mapping module
`s3-lambda-event-mapping` module (`samples/modules`) binds the event handling between the s3 create events 
and the lambda. It has 2 resources.
1. `aws_lambda_permission` - grants S3 to invoke the particular lambda 
2. `aws_s3_bucket_notification` - enables the lambda to listen for `s3:ObjectCreated` events 

#### (2) Bundle the lambda
This section will refer to the source `samples/08/s3ObjectListenerLambda.js` _(below)_.

##### (2.1) Lambda source
This is a simple lambda that will listen to 'object create' events from the S3 bucket. On receiving the events, 
the lambda will upload a metadata file with details of the object like, key, size, etag and time of
creation.

```javascript
const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event, context, callback) => {
  const uploadedObject = event.Records[0].s3.object;
  const objectKey = uploadedObject.key;
  if (!objectKey.includes('metadata.json')) {
    const metadata = {
      objectKey,
      objectSize: uploadedObject.size,
      objectETag: uploadedObject.eTag,
      objectCreationTime: event.Records[0].eventTime,
    };
    const bucketName = event.Records[0].s3.bucket.name;
    const metadataObjectKey = `${uploadedObject.key}-metadata.txt`;
    const s3Params = {
      Bucket: bucketName,
      Key: metadataObjectKey,
      Body: JSON.stringify(metadata),
      ServerSideEncryption: 'AES256',
      ContentType: 'text/plain'
    };
    s3.putObject(s3Params).promise()
      .then((data) => {
        console.log('Metadata uploaded');
        console.log(data);
      }).catch((err) => {
      console.log('Error occured uploading');
      console.log(err);
    });
    callback(null, `${metadataObjectKey} uploaded successfully.`);
  }
  callback(null, `${objectKey} ignored.`);
};
```

##### (2.2) AWS SDK Dependency
Node module `aws-sdk` is not required explicitly on lambda instances. It is available in those by default.

##### (2.3) Bundle the source
Let's bundle the lambda source using the following command (or) the script `bundle-lambda.sh` in `samples/08/`. Run these
commands from `samples/08/` folder.

```shell script
#!/bin/sh
zip /tmp/s3ObjectListenerLambda.zip s3ObjectListenerLambda.js
```

#### (3) Terraform Apply
Now we will run terraform script to create the `s3ObjectListenerLambda`.
You need to be in the `samples/08` folder to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

After terraform apply completes, the output on the console should look similar to the one below.

```shell script
module.lambda_tf_way_bucket.aws_s3_account_public_access_block.lambda_tf_way_s3_bucket_access: Creating...
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creating...
module.lambda_tf_way_bucket.aws_s3_bucket.lambda_tf_way_s3_bucket: Creating...
module.lambda_tf_way_bucket.aws_s3_account_public_access_block.lambda_tf_way_s3_bucket_access: Creation complete after 1s [id=919191919191]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 3s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.s3_object_listener_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_bucket.aws_s3_bucket.lambda_tf_way_s3_bucket: Creation complete after 3s [id=lambda-tf-way-bucket-101]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 2s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.s3_object_listener_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [10s elapsed]
module.s3_object_listener_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [20s elapsed]
module.s3_object_listener_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 22s [id=s3ObjectListenerLambda]
module.s3_lambda_event_mapping.aws_lambda_permission.lambda_tf_way_s3_permission: Creating...
module.s3_lambda_event_mapping.aws_s3_bucket_notification.lambda_tf_way_bucket_event: Creating...
module.s3_lambda_event_mapping.aws_lambda_permission.lambda_tf_way_s3_permission: Creation complete after 0s [id=terraform-20201227162154596200000001]
module.s3_lambda_event_mapping.aws_s3_bucket_notification.lambda_tf_way_bucket_event: Creation complete after 1s [id=lambda-tf-way-bucket-101]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:s3ObjectListenerLambda"
lambda_name = "s3ObjectListenerLambda"
lambda_tf_way_s3_bucket_arn = "arn:aws:s3:::lambda-tf-way-bucket-101"
lambda_tf_way_s3_bucket_name = "lambda-tf-way-bucket-101"
```

#### (4) Verify s3 event processing
This step will verify the event trigger from S3 bucket `lambda-tf-way-bucket-101` and `s3ObjectListenerLambda` 
processing the S3 event. On successful handling of this event, `s3ObjectListenerLambda` will create a metadata.txt 
file in the same bucket `lambda-tf-way-bucket-101`.

##### (4.1) Upload an Object to the S3 Bucket
Let's create a text file and upload it to the bucket. `upload-object.sh` file in `samples/08' contains the same script 
contents as below.

```shell script
#!/bin/sh
echo "Hello Lambda Terraform world" > helloworld.txt
aws s3api put-object --bucket lambda-tf-way-bucket-101 --key helloworld.txt --body helloworld.txt --profile "$AWS_PROFILE"
```
> output: Will be an etag of the uploaded object
> 

##### (4.2) Verify metadata object
Listing the objects in bucket `lambda-tf-way-bucket-101` will display the `helloworld.txt` file and 
also `helloworld.txt-metadata.txt` file. You can refer to `list-objects.sh` in `samples/08/` folder.

```shell script
aws s3api list-objects --bucket lambda-tf-way-bucket-101 --profile $AWS_PROFILE
```
> output: Will list helloworld.txt and helloworld.txt-metadata.txt file

```json
{
  "Contents": [
    {
      "Key": "helloworld.txt",
      "LastModified": "2020-12-27T16:38:33+00:00",
      "ETag": "\"12abc3de4f567g89h1ab1234567c89d0\"",
      "Size": 29,
      "StorageClass": "STANDARD",
      "Owner": {
        "ID": "a12b3c4d5678ef90123456a12b3c4d5678ef90123456a12b3c4d5678ef90123456"
      }
    },
    {
      "Key": "helloworld.txt-metadata.txt",
      "LastModified": "2020-12-27T16:38:35+00:00",
      "ETag": "\"12abc3de4f567g89h1ab1234567c89d0\"",
      "Size": 142,
      "StorageClass": "STANDARD",
      "Owner": {
        "ID": "a12b3c4d5678ef90123456a12b3c4d5678ef90123456a12b3c4d5678ef90123456"
      }
    }
  ]
}
```

Now, we can print the contents of the object `helloworld.txt-metadata.txt` as below. You can refer 
to `get-object-content.sh` in `samples/08/` folder.

```shell script
#!/bin/sh
aws s3api get-object --bucket lambda-tf-way-bucket-101 --key helloworld.txt-metadata.txt helloworld.txt-metadata.txt
cat helloworld.txt-metadata.txt
```

> output: Will print the content i.e., metadata of helloworld.txt, created by the s3ObjectListenerLambda.

```json
{
  "objectKey": "helloworld.txt",
  "objectSize": 29,
  "objectETag": "05d8304a09c852e59b9c641ebcbd660d",
  "objectCreationTime": "2020-12-27T16:38:31.291Z"
}
```

#### (5) Teardown
Let's remove the s3 objects and perform terraform destroy. Following commands should do. You can also refer to
`delete-objects.sh` script to delete the s3 obejcts.

>Note: Without deleting the objects, terraform will not destroy the s3 bucket.

```shell script
#!/bin/sh
aws s3api delete-object --key helloworld.txt-metadata.txt --bucket lambda-tf-way-bucket-101 --profile "$AWS_PROFILE"
aws s3api delete-object --key helloworld.txt --bucket lambda-tf-way-bucket-101 --profile "$AWS_PROFILE"
terraform destroy --auto-approve
```

🏁 **Congrats !** You learnt a key integration in serverless - AWS Lambda and S3. 🏁

**Next**: [Integrate with Kinesis](09-integrate-with-kinesis.md)
