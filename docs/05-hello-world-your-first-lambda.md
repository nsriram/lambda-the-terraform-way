# Hello World - Your First Lambda
This section explains how to deploy and invoke a lambda function using Terraform. Examples here will use 
NodeJS as the runtime. AWS Lambda supports other runtimes (Python, Ruby, Java, Go lang, .net) too. The document here
[AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) lists them in detail.

Terraform Scripts and lambda source code for this section are available in [Chapter 05](../samples/05).

#### (1) Build lambda archive
This section will bundle the lambda source in a `.zip` file. This will enable the Terraform script to upload the
lambda source zip file for deployment.

##### (1.1) Lambda source
The `helloWorldLambda.js` contains a simple nodejs AWS Lambda. Below snippet shows the same code. When invoked, 
the lambda returns a json payload with the current timestamp and a message.

```javascript
exports.handler =  async (event) => {
  const payload = {
    date: new Date(),
    message: 'Hello Terraform World'
  };
  return JSON.stringify(payload);
};
```

Note:
- `handler` module should be exported by the lambda js file.
- `handler` function is async and takes an `event` object.
- `event` object contains the request data from the caller.

#### (1.2) Compress the lambda source file
Packaging the `helloWorldLambda.js` file is done using the `zip` command (on Mac). From the `samples/05` directory, 
run the following to create a `.zip` file.

```shell script
zip -r /tmp/helloWorldLambda.zip helloWorldLambda.js
```

#### (2) Main Script
The main terraform script for creating the lambda is located in [Chapter 05](../samples/05) directory. This script 
creates the required IAM role for the lambda also.

##### (2.1) Lambda Role
For executing the lambda, it should be associated with a IAM role. Following section in `samples/05/main.tf` uses the 
`lambda-role` module to create the IAM Role.

> Note: No input variables are passed to the `lambda-role` module here. Because, this module will be reused for 
 the other lambda that will be creates in this tutorial.  

The next section will explain the `lambda-role` module.

```terraform
module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}
```

##### (2.1) Lambda Role Module
The `lambda-role` module is located at `samples/modules/lambda-role`. This module creates a IAM Role with 
assume-role-policy and also attaches the policies required for the lambda. 

Following are the 2 resources created in this module.

```terraform
resource "aws_iam_role" "lambda_tf_way_role" {
  name = "tf_way_lambda_role"
  assume_role_policy = file("${path.module}/lambda-assume-role-policy.json")
}

resource "aws_iam_role_policy" "tf_way_lambda_iam_role_policy" {
  name = "tf_way_lambda_role_policy"
  role = aws_iam_role.lambda_tf_way_role.id
  policy = file("${path.module}/lambda-policy.json")
}
```
###### lambda_tf_way_role
- The resource `lambda_tf_way_role` creates an IAM role with the `assume-role-policy.json` content.
- The `file` function assigns the contents of `lambda-assume-role-policy.json` to assume_role_policy.
- Assume role policy json allows the lambda service (lambda.amazonaws.com) to access other services on your 
  IAM account behalf. These are service roles. 
  Role [Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html#iam-term-service-role)
- The name of the role created is `tf_way_lambda_role`

###### lambda_tf_way_role_policy
- The resource `lambda_tf_way_role_policy` assigns policies to the `tf_way_lambda_role`. Contents of the 
  `lambda-policy.json` file are assigned as policy to the role.
- If you notice the `lambda-policy.json` file, it will allow access to the services S3, DynamoDB & SQS. For tutorial purpose 
  we will allow access to all the resources and actions. In general, the good practice is to assign specific resources
  and actions.

##### (2.2) Lambda
The `main.tf` in `samples/05` creates `hello_world_lambda` by using the lambda module in `samples/modules/lambda`.
Following is the script you will find in it.

- Lambda name, zip file containing the archived source (from step 1.2 above), handler function are passed
  as input variables.

```terraform
locals {
  lambda_name = "helloWorldLambda"
  zip_file_name = "/tmp/helloWorldLambda.zip"
  handler_name = "helloWorldLambda.handler"
}

module "hello_world_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}
```
###### tf_way_lambda_function
The `tf_way_lambda_function` resource is declared in the lambda module located at `samples/module/lambda`. This 
module creates the lambda function in AWS. The lambda module exports the function name and 
function ARN ([Amazon Resource Name](https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)). 

Following is the script you will find there.
- The runtime is configured as nodejs.
- Layers are optional, and `lambda_tf_way_layer` var has an empty string as default.

```terraform
resource "aws_lambda_function" "lambda_tf_way_function" {
  filename = var.lambda_zip_filename
  function_name = var.lambda_function_name
  handler = var.lambda_function_handler
  role = var.lambda_role_arn
  runtime = "nodejs12.x"
  layers = var.lambda_tf_way_layer == "" ? [] : [var.lambda_tf_way_layer]
}
```

#### (3) Terraform Apply
Now we will run terraform script to create the Lambda with its IAM Role. You need to be in the `samples/05` folder 
to run the script. 

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`  

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

> Note: Once terraform apply completes, it should print the Lambda and Role details as output.
The output on the console should look similar to the one below.

```
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creating...
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 4s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.hello_world_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 2s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.hello_world_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [10s elapsed]
module.hello_world_lambda.aws_lambda_function.lambda_tf_way_function: Still creating... [20s elapsed]
module.hello_world_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 22s [id=helloWorldLambda]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:helloWorldLambda"
lambda_name = "helloWorldLambda"
lambda_role_arn = "arn:aws:iam::919191919191:role/tf_way_lambda_role"
```

#### (4) Invoke the lambda
Now, we will invoke the function deployed using AWS CLI.

```shell script
aws lambda invoke --function-name helloWorldLambda \
    --log-type Tail \
    --payload '{}' \
    --profile "$AWS_PROFILE" outputfile.txt

cat outputfile.txt
```

You should see an output similar to the following after executing the lambda function.

> output
```json
"{\"date\":\"2019-01-01T12:00:00.000Z\",\"message\":\"Hello Terraform World\"}"
```

#### (5) Teardown (delete the lambda)
Now, we will delete the helloWorldLambda using terraform destroy. From the `samples/05/` folder run the 
following command. This will delete the lambda. 

```shell script
terraform destroy --auto-approve
```
> Note: Once destroy completes, you should see a log similar to the one below.
```
module.lambda_tf_way_role.aws_iam_role_policy.tf_way_lambda_iam_role_policy: Destroying... [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.hello_world_lambda.aws_lambda_function.tf_way_lambda_function: Destroying... [id=helloWorldLambda]
module.hello_world_lambda.aws_lambda_function.tf_way_lambda_function: Destruction complete after 0s
module.lambda_tf_way_role.aws_iam_role_policy.tf_way_lambda_iam_role_policy: Destruction complete after 1s
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Destroying... [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Destruction complete after 2s

Destroy complete! Resources: 3 destroyed.
```

🏁 **Congrats !** You deployed your first AWS Lambda function using Terraform and invoked it successfully. 🏁

**Next**: [View Lambda Logs](06-packaging-lambda-with-dependencies.md)
