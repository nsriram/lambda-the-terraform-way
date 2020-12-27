# Terraform Overview

This section is a short detour to explain the basics of terraform. We will cover a few Keywords, Commands and Functions. 

> Note: If you have already used terraform,
you may skip this section and move to [IAM Account For Tutorial](04-iam-account-setup.md).

## Keywords
Terraform is a declarative language that allows creation of infrastructure resources on cloud platforms. 

### Provider
Terraform supports various cloud providers like GCP, AWS, Azure etc.,. Terraform code interacts with providers 
via specific plugins. Following is a simple provider declaration for creating and managing resources in AWS, 
for region `ap-south-1`.

[Provider Reference](https://www.terraform.io/docs/configuration/blocks/providers/index.html) 

```hcl-terraform
provider "aws" {
  region = "ap-south-1"
}
```
### Resource
Resource forms the core of terraform code. They map to infrastructure objects corresponding to a specific provider.
Following is a simple resource block that creates a S3 bucket. Here, the `lambda-tf-bucket` corresponds to a local
name that can be used for referencing in terraform code. The actual bucket will be created 
with name `lambda-tf-tutorial-bucket`.

[Resource Reference](https://www.terraform.io/docs/configuration/blocks/resources/index.html)

```hcl-terraform
resource "aws_s3_bucket" "lambda-tf-bucket" {
  bucket = "lambda-tf-tutorial-bucket"
}
```
### Input Variables
Input variables are like variables in most of the general purpose programming languages. They can also be considered 
as similar to function arguments. Following is a simple usage of a variables `aws_region` and `bucket_name`.

[Input Variable Reference](https://www.terraform.io/docs/configuration/variables.html)

```hcl-terraform
variable "aws_region" {
  default = "ap-south-1"
}

provider "aws" {
  region = var.aws_region
}

variable "bucket_name" {
  default = "ap-south-1"
}

resource "aws_s3_bucket" "lambda-tf-bucket" {
  bucket = var.bucket_name
}

```

### Output Values
Output values can be considered as function return values. When terraform script executes and creates a resource, the
resource attributes can be mapped to output values. For example, the ARN for the bucket created in the input variables 
(previous section) can be mapped as an output value, as the ARN will be available only after execution.
[Output Value Reference](https://www.terraform.io/docs/configuration/outputs.html)

```hcl-terraform
variable "bucket_name" {
  default = "ap-south-1"
}

resource "aws_s3_bucket" "lambda-tf-bucket" {
  bucket = var.bucket_name
}

output "bucket_arn" {
  value = aws_s3_bucket.lambda-tf-bucket.arn
}
```

### Terraform State
When the terraform script is run, the state of the infrastructure created is managed. By default the state is stored 
in a file named `terraform.tfstate` in the directory `.terraform` _(from the place the script was run)_. 
Terraform primarily uses state for mapping the resources declared in the files to real world objects, managing 
metadata of the resources _(e.g., resource dependency)_ , performance via cache and finally syncing.
[State Reference](https://www.terraform.io/docs/state/index.html)

#### Remote State
The state can also be managed in a remote store. It is considered a best practice to store the state in a remote store
when working in teams involving multiple people. Terraform performs locking if the backend (Remote) support locking.
This helps in a team from overriding the state during concurrent execution. For e.g., S3 and DynamoDB can be configured 
to support remote backend with locking. Following is an example for remote state declaration using S3 & DynamoDB 
using the keyword `terraform`.

> Note: This tutorial series will not use Remote backend.  

>[Remote State Reference](https://www.terraform.io/docs/state/remote.html)

```hcl-terraform
terraform {
  backend "s3" {
    region = "ap-south-1"
    bucket = "my-terraform-state-bucket"
    key = "lambda-tf-way-state-key"
    dynamodb_table = "my-terraform-state-table"
    encrypt = true
  }
}
```
### Modules
Modules are a very important part of terraform code. They help in re-usability of code. They are like functions
that can be invoked with variables. The modules will substitute the values passed and create the resources.
For e.g., say we have a module for s3 bucket creation in `/terraform/modules/s3/main.tf` as below, without a default
value. The ARN of the bucket can be exported/returned as an output.

```hcl-terraform
variable "bucket_name" {
}

resource "aws_s3_bucket" "lambda-tf-bucket" {
  bucket = var.bucket_name
}

output "bucket_arn" {
  value = aws_s3_bucket.lambda-tf-bucket.arn
}

```

The above module can be invoked from a `main.tf` file located in `/terraform/main.tf` as below, multiple times to 
create as many s3 buckets.
```hcl-terraform
module "my_first_s3_bucket" {
  source = "./modules/s3"
  bucket_name = "first_bucket"
}

output "first_bucket_arn" {
  value = aws_s3_bucket.my_first_s3_bucket.bucket_arn
}

module "my_second_s3_bucket" {
  source = "./modules/s3"
  bucket_name = "second_bucket"
}

output "second_bucket_arn" {
  value = aws_s3_bucket.my_second_s3_bucket.bucket_arn
}
```

Above are some of the keywords and concepts that are required for understanding this tutorial.

## Commands
This section explains the important terraform commands that we will be using in this series.

#### Init
Init command initialises the working directory containing the terraform script files. This should be the first command 
executed. This command also installs the provider plugins based on the script. When new modules are included to your
script, initialization should be done. 

*Usage* :  `terraform init`

[Init Reference](https://www.terraform.io/docs/commands/init.html)

#### Validate
Validate command as its name implies, validated the script file. It does not make a remote call to the 
resource provider (e.g, AWS or GoogleCloud) to validate. It does only a local validation. Its a good practice
to check for syntactical errors before executing the scripts.

*Usage* :  `terraform validate` 

[Validate Reference](https://www.terraform.io/docs/commands/validate.html)

#### Plan
Terraform plan displays the resources that are to be created, modified or destroyed. Output of this command can be 
matched against the intended plan. Its a good practice to check the plan of the scripts to be executed.  
https://www.terraform.io/docs/commands/plan.html

*Usage* :  `terraform plan` 

[Plan Reference](https://www.terraform.io/docs/commands/plan.html)

#### Apply
Terraform apply is the command that performs the resource management in a provider i.e., creates, updates or deletes a
resource. Apply when executed, lists the resources that will be managed and expects the person performing the action
to approve. Apply can also be performed with `--auto-approve`, but is recommended that the plan is checked before 
auto approving.  

*Usage* :  `terraform apply --auto-approve`
 
[Apply Reference](https://www.terraform.io/docs/commands/apply.html)

#### Output
Terraform output will print the output values declared in the terraform script. It can also be invoked with a 
specific output field.

*Usage* :  `terraform output`
 
[Output Reference](https://www.terraform.io/docs/commands/output.html)

#### Destroy
Terraform destroy command destroys the entire infra created. It also expects the user to supply the approval, if the
`--auto-approve` is not passed.
> Note: terraform destroy can be previewed using `terraform plan -destroy`

*Usage* :  `terraform destroy`
 
[Output Reference](https://www.terraform.io/docs/commands/destroy.html)

## Functions

### file
The file function reads the contents of a file from the given path. For e.g., below terraform script assigns the content
of the file `lambda-assume-role-policy.json` in the module path and assigns it to `assume_role_policy`.

```terraform
resource "aws_iam_role" "lambda_tf_way_role" {
  name = "tf_way_lambda_role"
  assume_role_policy = file("${path.module}/lambda-assume-role-policy.json")
}
```
[file Reference](https://www.terraform.io/docs/configuration/functions/file.html)

🏁 **Congrats !** You completed the fastest introduction to Terraform 🏁

**Next**: [IAM Account For Tutorial](04-iam-account-setup.md)