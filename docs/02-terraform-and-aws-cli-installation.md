# Prerequisites and Setup

### AWS Account
Examples used in this tutorial will be run on MacOS. We will need AWS Account, AWS CLI, Terraform and Keybase app 
to be installed.

You can sign-up for a new AWS account if you don't have one here [Sign-up AWS](https://portal.aws.amazon.com/billing/signup#/start). 
AWS lambda offers free tier up to 1 million requests per month. This is applicable for both existing and new customers.

### Installation

#### Terraform
On Mac, simple way to install terraform is by using Homebrew. The homebrew formulae for Terraform is available here
[Terraform Homebrew Formulae](https://formulae.brew.sh/formula/terraform)
Following command should help in installing Terraform. 

```shell script
brew install terraform
```

The version of terraform installed on your machine can be verified as below.

```shell script
➜  ~ terraform version
Terraform v0.14.2
```
**Note**: The examples in this tutorial are run on the above version of terraform _(latest while writing this tutorial)_.

#### AWS CLI
AWS [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html) here, explains the necessary 
steps to install AWS CLI tool. Post installation, you can verify using the version command. 

```shell script
➜  aws --version
aws-cli/2.1.1 Python/3.9.0 Darwin/19.0.0 source/x86_64
```

The examples in this tutorial are run on the above version of AWS CLI _(latest while writing this tutorial)_. 
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

### Samples
> All the samples used in this series are available in `samples` folder.
> Lambda language is NodeJS. ES6 is not used to avoid the extra steps pf babel and bundling node_modules.
> Values like AWS Account ID etc., in the samples are masked

### Keybase App

We will use Keybase app as the pgp provider. This will be used by terraform to the AWS (web) console password. 
If you do not have one installed, you can install using the steps provided here.

[Install Keybase on MacOS](https://keybase.io/docs/the_app/install_macos)

🏁 **Congrats !** You got your Terraform and AWS CLI Setup complete 🏁

**Next**: [Terraform Overview](03-terraform-overview.md)