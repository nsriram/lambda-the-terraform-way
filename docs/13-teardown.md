# Teardown

This is the last section in the **'Lambda the Terraform way'** series. As we progressed through various sections, we have
been deleting all the resources created in those _(e.g., lambdas, s3 assets, kinesis queues etc.,)_

### Delete IAM Account Setup
At this point only the resources created in `samples/04` are left. 
Let's delete them from `samples/04` and your AWS_PROFILE should be the admin user profile.

```shell script
export AWS_PROFILE=<aws_admin_user_profile>
terraform destroy --auto-approve
```

### Delete AWS Config
Please do ensure you remove the lambda-tf-user from `~/.aws/credentials`

🏁 **Congrats !** This completes the "Lambda, the Terraform Way" series 🏁 
