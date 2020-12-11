# Prerequisites and Setup

### AWS Account
Examples used in this tutorial will be run on MacOS. We will need AWS Account, AWS CLI and Terraform to be installed.

You can sign-up for a new AWS account if you don't have one here [Sign-up AWS](https://portal.aws.amazon.com/billing/signup#/start). 
AWS lambda offers free tier up to 1 million requests per month. This is applicable for both existing and new customers.

### Installation

#### Terraform
On Mac, simple way to install terraform is by using Homebrew. The homebrew formulae for Terraform is available here
[Terraform Homebrew Formulae](https://formulae.brew.sh/formula/terraform)
Following command should help in installing Terraform. 

```
➜  brew install terraform
```

The version of terraform installed on your machine can be verified as below.

```
➜  ~ terraform version
Terraform v0.14.2
```
**Note**: The examples in this tutorial are run on the versions above _(latest while writing this tutorial)_.

#### AWS CLI
AWS [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) here, explains the necessary 
steps to install AWS CLI tool. Post installation, you can verify using the version command. 

```
➜  aws --version
aws-cli/2.1.1 Python/3.9.0 Darwin/19.0.0 source/x86_64
```

The examples in this tutorial are run on the versions above _(latest while writing this tutorial)_. 
You can also verify the current (root) user configured for CLI, by using the command below.
```
➜  aws configure list
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                <not set>             None    None
access_key     ****************XYXY shared-credentials-file
secret_key     ****************aBcd shared-credentials-file
    region                us-east-1      config-file    ~/.aws/config
```

#### Quick Notes
- `~/.aws` _(dot aws)_ folder in your user home is a location where AWS CLI references for configuration & credentials. 
- `~/.aws/config` file is used for specifying various aws profiles.
    The `[default]` profile entry here will be used by AWS CLI, for executing the commands. 
- `~/.aws/credentials` is a file where the `aws_access_key_id` and `aws_secret_access_key` of the profiles can be specified. 

**Note**: `aws_secret_access_key` is mentioned in plain text in ~/.aws/credentials file. This is not recommended for 
security reasons, if you are on a shared laptop or feel, the file can be accessed by others. But, we will proceed with 
this tutorial using this approach. At th end of the tutorial the credentials will be removed. 

🏁 **Congrats !** You got your Terraform and AWS CLI Setup complete 🏁

**Next**: [IAM Account For Tutorial](03-iam-account-setup.md)