# Packaging AWS Lambda function with dependencies

This section explains how to deploy a lambda function with library dependencies (on Node JS). Most of the parts
will be similar to previous section. The change will be in the way the source is bundled. We will notice how terraform 
modules can be reused here.

Samples for this tutorial are available in `samples/06` folder.

#### (1) Install accounting.js dependency
Following example will use a node.js library `accounting.js` to format a number into currency. 
`formatCurrencyLambda.js` contains the lambda source. 

From the `samples/06` folder execute the following command to install accounting.js

```shell script
npm install accounting
```

#### (2) Compress lambda source with dependencies
Here, we will bundle the source file with its `node_module` dependencies. The compressed `formatCurrencyLambda.zip`
is the artifact will be deployed using Terraform.

> Note: node_modules folder is included in the compressed formatCurrencyLambda.zip. 

```shell script
zip -r /tmp/formatCurrencyLambda.zip node_modules formatCurrencyLambda.js
```

#### (3) Terraform script for formatCurrencyLambda
Terraform script for deploying `formatCurrencyLambda` in AWS is in `main.tf`. This script (below) reuses the 
modules lambda and lambda-role.

- Only the locals values are changed to reflect the lambda name and zip file name. Otherwise, this script 
is very similar to the helloWorldLambda's `main.tf`
- Only the module reference has changed in `output.tf`. Otherwise, `vars.tf` and `output.tf` haven't changed as well.

```terraform
provider "aws" {
  region = var.aws_region
}

module "lambda_tf_way_role" {
  source = "../modules/lambda-role"
}

locals {
  lambda_name = "formatCurrencyLambda"
  zip_file_name = "/tmp/formatCurrencyLambda.zip"
  handler_name = "formatCurrencyLambda.handler"
}

module "format_currency_lambda" {
  source = "../modules/lambda"
  lambda_function_name = local.lambda_name
  lambda_function_handler = local.handler_name
  lambda_role_arn = module.lambda_tf_way_role.lambda_role_arn
  lambda_zip_filename = local.zip_file_name
}
```

#### (4) Terraform Apply
Now we will run terraform script to create the Format Currency Lambda (with its IAM Role). 
You need to be in the `samples/06` folder to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

#### (5) Invoke the lambda to test the dependency
We will invoke the formatCurrencyLambda via AWS CLI to test the deployment.

> Note: If you are on AWS CLI v2, you have include the param `--cli-binary-format raw-in-base64-out`.

```shell script
aws lambda invoke --function-name formatCurrencyLambda \
    --log-type Tail \
    --cli-binary-format raw-in-base64-out \
    --payload '{"value": 123456789}' \
    --profile "$AWS_PROFILE" \
    outputfile.txt
```

Print the contents `outputfile.txt` to see the formatted value of `123456789` as `$123,456,789.00`.

```shell script
cat outputfile.txt

> Output :
{"amount":"$123,456,789.00"}%
```

#### (6) Teardown
Now, we will delete the formatCurrencyLambda using terraform destroy, similar to helloWorldLambda. 
From the `samples/06/` folder run the following command. 

```shell script
export AWS_PROFILE=lambda-tf-user
terraform destroy --auto-approve
```

> Note: Once destroy completes, you should see a log similar to the one below.
```
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Destroying... [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.format_currency_lambda.aws_lambda_function.lambda_tf_way_function: Destroying... [id=formatCurrencyLambda]
module.format_currency_lambda.aws_lambda_function.lambda_tf_way_function: Destruction complete after 0s
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Destruction complete after 1s
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Destroying... [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Destruction complete after 3s

Destroy complete! Resources: 3 destroyed.
```

🏁 **Congrats !** You deployed your 'first Lambda with dependencies' using Terraform and invoked it successfully. 🏁

**Next**: [Lambda Layers](07-lambda-layers.md)