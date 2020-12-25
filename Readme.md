# AWS Lambda the Terraform Way

The objective of this tutorial is to understand AWS Lambda in-depth, beyond executing functions, using Terraform. 
This tutorial walks through setting up Terraform, dependencies for AWS Lambda, getting your first Lambda function running, 
many of its important features & finally integrating with other AWS services. 

### Terraform
[Terraform](https://www.terraform.io/) will be the primary medium of demonstrating all these examples. 
Terraform is an infrastructure as code software that helps in managing resources in cloud, by various providers like 
AWS, GCP, Azure etc., Terraform enables creation of infrastructure by writing code in a declarative form.

### Target Audience
Target audience for this tutorial series are developers with basic knowledge of Terraform. 
A little background on understanding of serverless technologies, infrastructure as code will help. 
> Note : The tutorial will not discuss examples using the AWS website UI (or) with AWS SDK.     

## Tutorials

1. [Serverless Introduction](docs/01-serverless-introduction.md)
2. [Prerequisites and Setup](docs/02-terraform-and-aws-cli-installation.md)
3. [Terraform Overview](docs/03-terraform-overview.md)
4. [IAM Account For Tutorial](docs/04-iam-account-setup.md)
5. [Hello World - Your First Lambda](docs/05-hello-world-your-first-lambda.md)
6. View Lambda Logs
7. Packaging With Dependencies
8. Lambda Layers
9. Version Lambda
10. Managing Lambda
11. Integrate with S3
12. Integrate with Kinesis
13. Integrate with DynamoDB
14. Integrate with SQS
15. Integrate with APIGateway
16. Tear down

**Let's Get Started**: [Serverless Introduction(docs/01-serverless-introduction.md)

## References (external)
- [Terraform](https://www.terraform.io/)
- [AWS Lambda](https://aws.amazon.com/lambda/)
- [Google Cloud Functions](https://cloud.google.com/functions/)
- [Azure Functions](https://azure.microsoft.com/en-gb/services/functions/)
- [Apache OpenWhisk](https://openwhisk.apache.org/)
- [KNative](https://cloud.google.com/knative/)
- [Kubeless](https://kubeless.io/)
- [Serverless](https://serverless.com/)  

