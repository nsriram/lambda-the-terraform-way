# IAM Account Setup (for tutorial purpose)

## AWS IAM Profile
Creating individual IAM Users is an AWS best practice. Through IAM, permissions can be restricted to the 
required AWS resources and actions for a particular user. For this tutorial series, we will 
the IAM User `lambda-tf-user`.

Following sections will walk through the steps required to create `lambda-tf-user` and assigning specific permissions 
to that user id.

> Note: It is assumed that you have the AWS admin user configured for performing IAM related activities.

Scripts for this section are available in [Chapter 04](../samples/04).

#### (1) Main Script
`main.tf` terraform script in `samples/04` creates the IAM User. Let's understand `main.tf` line by line. 

```terraform
provider "aws" {
  region = var.aws_region
}

module "lambda_tf_way_user_module" {
  source = "../modules/iam"
  iam_username = "lambda-tf-user"
}

output "access_key" {
  value = module.lambda_tf_way_user_module.access_key
}

output "secret" {
  value = module.lambda_tf_way_user_module.secret
}
``` 

- The provider block declares AWS as the infra resource provider. It also provides the region as `ap-south-1`. 
> Note: the region is declared as a variable in `vars.tf`. It is a good practice to declare variables in a separate file
and output values in a separate file.
- The module section uses the [IAM Module](../samples/modules/iam). Following section will detail the IAM module
##### Output Values
- Two output values are declared in `output.tf`. They are the user's access key and secret. These will be used for 
configuring the `~/.aws/credentials` for the tutorial purpose.
> Note: When the `main.tf` script is run the resources will be created, and the output values will be 
printed on the console.

#### (2) IAM Module
The IAM module is responsible for creating the IAM User, AccessKey & SecretKey pair. The module also associates 
the required policies to the IAM user. 
- `main.tf` file (in IAM module) contains the script for creating all these resources.
- Three policies are attached with all privileges to the IAM user
1. AWSLambda_FullAccess
2. IAMFullAccess
3. AmazonS3FullAccess
4. AmazonKinesisFullAccess

>Note: It is a good practice to provide specific permissions instead of Full permissions. To keep it simple for 
the tutorial we will grant full access.  

- The module exports the `access_key` and `secret` via the `output.tf` file.

#### (3) Terraform Apply
Now we will run terraform script to create the IAM user. You need to be in the `samples/04` folder to run the script. 

```shell script
terraform init
terraform apply --auto-approve  
```
> Note: Once terraform completes, it should print the Access Key and Secret as below. 
The output on the console should look similar to the one below.
Terraform apply will also create `.terraform` folder with tfstate files in `samples/04` directory.

```shell script
module.lambda_tf_way_user_module.aws_iam_user.lambda_tf_way_iam_user: Creating...
module.lambda_tf_way_user_module.aws_iam_user.lambda_tf_way_iam_user: Creation complete after 3s [id=lambda-tf-user]
module.lambda_tf_way_user_module.aws_iam_access_key.lambda_tf_way_access_key: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_lambda_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_iam_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_s3_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_kinesis_policy: Creating...
module.lambda_tf_way_user_module.aws_iam_access_key.lambda_tf_way_access_key: Creation complete after 1s [id=ABCDEABCDEABCDEABCDEA]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_lambda_policy: Creation complete after 4s [id=lambda-test-user-lambda-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_iam_policy: Creation complete after 4s [id=lambda-test-user-iam-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_s3_policy: Creation complete after 4s [id=lambda-test-user-s3-policy-attachment]
module.lambda_tf_way_user_module.aws_iam_policy_attachment.lambda_tf_way_kinesis_policy: Creation complete after 4s [id=lambda-test-user-kinesis-policy-attachment]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

access_key = "ABCDEABCDEABCDEABCDEA"
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

#### (6) List AWS Lambda functions using IAM User
We will set the AWS_PROFILE to `lambda-tf-user`. In the next sections, this env variable will be used by terraform
to perform resource level operations. 

We will execute the following AWS CLI command to verify a simple check on the newly created user.

```shell script
➜  export AWS_PROFILE=lambda-tf-user
➜  aws lambda list-functions --profile lambda-tf-user
```
You should see an output listing empty list of functions, or the ones your IAM user has access to.
>Output:
```json
{
  "Functions": []
}
```

🏁 **Congrats !** You created your first AWS IAM User using terraform and granted permissions 🏁. 

**Next**: [Hello World - Your First Lambda](05-hello-world-your-first-lambda.md)