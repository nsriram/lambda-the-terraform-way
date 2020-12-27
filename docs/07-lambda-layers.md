# Lambda Layers

This article outlines the steps involved in building a node js lambda using lambda layers for library dependencies.

The example will build a lambda function that will return current time using [momentjs](https://github.com/moment/moment/)
library. The lambda will not bundle `moment.js` via `node_modules`, as we did in [previous tutorial](06-packaging-lambda-with-dependencies.md)
but, will use [lambda layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html).

### What is a lambda layer ?
**(Source: AWS Docs)** : 
- A layer is a ZIP archive that contains libraries, a custom runtime, or other dependencies. 
- With layers, you can use libraries in your function without needing to include them in your deployment package. 

#### (1) Publish the layer
We will bundle the node_modules for the moment.js library and publish to AWS as a layer. 

##### (1.1) Create the lambda layer
* The package.json in `samples/07/momentjs-lambda-layer` folder declares moment.js as a dependency.
* The packaging should use the folder structure shown below for nodejs lambda layers.
  This folder structure is a requirement from lambda layers.
* Move the `node_modules` into `nodejs` subdirectory and package them as a zip archive file.

Following steps will bundle the archive required for creating the lambda layer. Run the following commands from
`samples/07/momentjs-lambda-layer` folder (or) you can run the `bundle-layer.sh` script in 
the same folder.

>Note: Here we are moving the package.json to a dist/nodejs folder, installing the package and bundling the nodejs
folder in an archive named momentJSLambdaLayer.zip

```shell script
#!/bin/sh
mkdir -p dist/nodejs
cp package.json dist/nodejs
cd dist/nodejs
npm install
cd ..
zip -r /tmp/momentJSLambdaLayer.zip nodejs
cd ..
rm -rf dist
```

#### (2) Bundle the lambda
This section will refer to the source in `samples/07/current-time-lambda` folder and `currentTimeLambda.js` source _(below)_.

```javascript
const moment = require('moment');

exports.handler = (event, context, callback) => {
  const time = moment().format('MMMM Do YYYY, h:mm:ss a');
  callback(null, { time });
};
```

**_Note_** :
- The lambda source has reference to moment.js, but moment.js is not included in package.json.
- We will attach the lambda layer that was created earlier to this lambda in following steps.

Let's bundle the lambda source without its dependencies from `samples/07/current-time-lambda` folder using 
the following command (or) the script `bundle-lambda.sh` in `samples/07/current-time-lambda`.

```shell script
#!/bin/sh
zip /tmp/currentTimeLambda.zip currentTimeLambda.js
```

#### (3) Terraform script for currentTimeLambda and momentJSLambdaLayer

Terraform script in `samples/07/main.tf` (below) will create the following resources

1. momentJSLambdaLayer (lambda layer)
2. currentTimeLambda (lambda with its role)

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  layer_name = "momentJSLambdaLayer"
  layer_payload = "/tmp/momentJSLambdaLayer.zip"
  
  lambda_name = "currentTimeLambda"
  zip_file_name = "/tmp/currentTimeLambda.zip"
  handler_name = "currentTimeLambda.handler"
}

module "moment_js_lambda_layer" {
  source = "../modules/lambda-layer"
  lambda_layer_name = local.layer_name
  lambda_layer_payload = local.layer_payload
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

module "current_time_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
  lambda_tf_way_layer = module.lambda_tf_way_layer.lambda_tf_way_layer_arn_with_version
}

```
- Module `moment_js_lambda_layer` creates a lambda layer with payload pointing to `/tmp/momentJSLambdaLayer.zip`
- Module `current_time_lambda` creates a lambda with payload pointing to `/tmp/currentTimeLambda.zip`. The layer is
  attached to this lambda by passing the ARN of the lambda layer `moment_js_lambda_layer` created earlier.


#### (4) Terraform Apply
Now we will run terraform script to create the MomentJS Lambda layer, and Current time lambda.
You need to be in the `samples/07` folder to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

### (5) Invoke lambda

### (5.1) Invoke the lambda
We will invoke the currentTimeLambda via AWS CLI to test the deployment of lambda with momentjs lambda layer.

```shell script
aws lambda invoke \
    --function-name currentTimeLambda \
    --profile "$AWS_PROFILE" \
    --log-type Tail \
    --cli-binary-format raw-in-base64-out \
    --payload '{}' outputfile.txt
```

Successful invocation should list a response similar to the following.

```json
{
  "LogResult": "A1BCDefghiJKLmnOPQRSt2OWZmMzMwMS0yY2IxLTQ5Y2ItOGJlMS0yMWQwNGZ...TYyLjk2IG1zCQo=",
  "ExecutedVersion": "$LATEST",
  "StatusCode": 200
}
```
### (5.2) View the output
- To ensure the current time is responded by currentTimeLambda, view the contents of `outputfile.txt` file. You should
see an output similar to the one below.

```shell script
> cat outputfile.txt
{"time":"January 1st 2020, 01:00:00 pm"}
```

#### (6) Teardown
Now, we will delete the currentTimeLambda and momentJSLambdaLayer, using terraform destroy.
From the `samples/07/` folder run the following command.

```shell script
terraform destroy --auto-approve
```

🏁 If you have seen the timestamp, **Congrats !** You got your first lambda layer working using Terraform 🏁

**Next**: [Integrate with S3](08-integrate-with-s3.md)