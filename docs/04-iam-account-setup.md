# IAM Account Setup (for tutorial purpose)

## AWS IAM Profile
Creating individual IAM Users is an AWS best practice. Through IAM, permissions can be restricted to the 
required AWS resources and actions. For this tutorial series, we will create the IAM User `lambda-tf-user`.

Following sections will walk through the steps required to create `lambda-tf-user` and assigning specific permissions 
to that user id.

Scripts for this section are available in [Chapter 04](../samples/04).

> Note: It is assumed that you have the AWS admin user configured for performing IAM related activities.

#### (1) Main Script
`main.tf` terraform script in `samples/04` creates the IAM User. Let's understand `main.tf` line by line. 

```terraform
provider "aws" {
  region = var.aws_region
}

module "lambda_tf_way_user_module" {
  source = "../modules/iam"
  iam_username = "lambda-tf-user"
  pgp_key = "keybase:${var.keybase_id}"
  keybase_id = var.keybase_id
}
``` 
##### Input Variables
- The provider block declares AWS as the infra resource provider. It also provides the region as `ap-south-1`. 
**Note**
-  The region is declared as a variable in `vars.tf`. It is a good practice to declare variables in a separate file
and output values in a separate file.
-  The value for the variable `keybase_id` will be passed via the CLI environment using `TF_VAR` of Terraform.

##### Modules
The `main.tf` in `samples/04` uses the [IAM Module](../samples/modules/iam). Following section will detail the IAM module

##### Output Values

- Four output values are declared in `output.tf`. 
  1. access_key - AWS Access Key fpr the IAM User
  2. secret - AWS Secret for the Access Key
  3. username -  User login via web
  4. password - encrypted password for the user login

-  Access key and Secret will be configured in  `~/.aws/credentials` for tutorial purpose.

> Note: When the `main.tf` script is run the resources will be created, and the output values will be 
printed on the console.

#### (2) IAM Module
The IAM module is responsible for creating the 
1. IAM User
2. AccessKey SecretKey pair 
3. IAM (web) Console username, password. 

The module also associates the required policies to the IAM user. 

- `main.tf` file (in IAM module) contains the script for creating all these resources.
- The module exports the `access_key`, `secret` via the `output.tf` file. 
- The module also exports the `username` and encrypted `password`

- Following '7'policies are attached with all privileges to the IAM user
1. `AWSLambda_FullAccess`
2. `IAMFullAccess`
3. `AmazonS3FullAccess`
4. `AmazonKinesisFullAccess`
5. `AmazonDynamoDBFullAccess`
6. `AmazonSQSFullAccess`
7. `AmazonAPIGatewayAdministrator`

>Note: It is a good practice to provide specific permissions instead of Full permissions. To keep it simple for 
the tutorial we will grant full access.  

#### (3) Terraform
Now we will run terraform script to create the IAM user. You need to be in the `samples/04` folder to run the script. 

##### TF_VAR keybase_id 
Before we can run the `main.tf` terraform script, we have to configure the keybase id as a `TF_VAR`. 
`TF_VAR`s allow values to be passed to terraform variables via environment. The variable declared in `main.tf` 
should be prefixed by `TF_VAR_` i.e., `TF_VAR_keybase_id`.

You can provide this value for your id as below, by replacing the `key_base_userid` field.

```shell script
export TF_VAR_keybase_id=key_base_userid
```

##### Terraform Apply
After setting `TF_VAR_keybase_id` environment variable, lets run terraform apply.
```shell script
terraform init
terraform apply --auto-approve  
```
> Note: After terraform completes, it should print the 4 output variables as below (similar). 
Terraform apply will also create `.terraform` folder with tfstate files in `samples/04` directory.

>Note: The values in output are masked. You will see the actual values when you run.

```shell script
module.lambda_tf_way_user_module.aws_iam_user.lambda_tf_way_iam_user: Creating...
module.lambda_tf_way_user_module.aws_iam_user.lambda_tf_way_iam_user: Creation complete after 3s [id=lambda-tf-user]
module.lambda_tf_way_user_module.aws_iam_user_login_profile.lambda-test-user-profile: Creating...
module.lambda_tf_way_user_module.aws_iam_access_key.lambda_tf_way_access_key: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_dynamodb_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_kinesis_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_lambda_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_s3_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_iam_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_sqs_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_api_gateway_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_access_key.lambda_tf_way_access_key: Creation complete after 1s [id=ABCDEABCDEABCDEABCDEA]
module.lambda_tf_way_user_module.aws_iam_user_login_profile.lambda-test-user-profile: Creation complete after 2s [id=lambda-tf-user]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_dynamodb_policy: Creation complete after 3s [id=lambda-test-user-dynamodb-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_api_gateway_policy: Creation complete after 3s [id=lambda-test-user-api-gateway-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_iam_policy: Creation complete after 3s [id=lambda-test-user-iam-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_kinesis_policy: Creation complete after 3s [id=lambda-test-user-kinesis-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_s3_policy: Creation complete after 5s [id=lambda-test-user-s3-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_sqs_policy: Creation complete after 6s [id=lambda-test-user-sqs-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_lambda_policy: Still creating... [10s elapsed]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_lambda_policy: Creation complete after 13s [id=lambda-test-user-lambda-policy-attachment]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

access_key = "ABCDEABCDEABCDEABCDEA"
password = "aBcDEeFG1H2IjKlM3nOPQrS4Tuv5W6xYZaB+7CdEf8g=/abcd1234/aBcDEeFG1H2IjKlM3nOPQrS4Tuv5W6xYZaB+7CdEf8g=+aBcDEeFG1H2IjKlM3nOPQrS4Tuv5W6xYZaB+7CdEf8g=/abCDefgH/aBcDEeFG1H2IjKlM3nOPQrS4Tuv5W6xYZaB+7CdEf8g="
secret = "AbcdEF1ghijK+lMNOPQ2+Rs3ST4uvwXyzaBcde5f"
```

#### (4) Add IAM user configuration to CLI config
The Access Key and the Secret from the previous step should be configured in `~/.aws/credentials` as below . 

```
[lambda-tf-user]
aws_access_key_id = ABCDEABCDEABCDEABCDEA
aws_secret_access_key = AbcdEF1ghijK+lMNOPQ2+Rs3ST4uvwXyzaBcde5f
```

Add the profile and region entries to `~/.aws/config` as below .
> Note: Here the profile name configured is `lambda-tf-user` and the region is `ap-south-1`. You are free to configure
the region you would like to.  

```
[profile lambda-tf-user]
region = ap-south-1
```

#### (5) List AWS Lambda functions using IAM User
We will set the AWS_PROFILE to `lambda-tf-user`. In the next sections, this env variable will be used by terraform
to perform resource level operations.

We will execute the following AWS CLI command to verify a simple check on the newly created user.

```shell script
export AWS_PROFILE=lambda-tf-user
aws lambda list-functions --profile lambda-tf-user
```
You should see an output listing empty list of functions, or the ones your IAM user has access to.
>Output:
```json
{ "Functions": [] }
```

#### (6) AWS Console (web) username and password
Following command can be used to decrypt and retrieve the console (web) password from Terraform output. You can 
use a browser and login to the Web console using the username, decrypted password and admin AWS account number.

You need to have the Keybase.app open while running this command.

>Note: For the tutorial we will not use the web console. But it will be useful to see logs and understand. Hence, it 
> has been included.

```shell script
terraform output -json password | jq -r . | base64 --decode | keybase pgp decrypt
```

You can get the username using the below command
```shell script
terraform output username
```

🏁 **Congrats !** You created your first AWS IAM User using terraform and granted permissions 🏁. 

**Next**: [Hello World - Your First Lambda](05-hello-world-your-first-lambda.md)