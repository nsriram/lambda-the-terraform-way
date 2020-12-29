# Integrate with API Gateway
This section will provide a walk through on integration between AWS Lambda and Amazon API gateway. Lambda functions
can be exposed as APIs using API Gateway

### Amazon API Gateway
Amazon API Gateway is another managed service from AWS, that helps developers in exposing their applications as APIs. It
also takes away the considerable operational overhead of managing API related functionality like traffic management,
monitoring, securing APIs, throttling and more.  Three types of APIs can be exposed via API Gateways -
1. HTTP APIs
2. REST APIs
3. Websocket APIs
> Our example will focus around API Gateway's REST API to expose a Lambda function.

#### Integration Example
We will integrate the API Gateway's REST API to `currentTimeLambda.js`. When the API Gateway's REST API URL is accessed, 
lambda will be invoked. Lambda response _(current time)_ will be returned to the user (by the API Gateway). 

#### (1) Terraform
`main.tf` script (below) in `samples/12/` does the following

- Creates an REST API Gateway `TimeAPI` that supports `GET` HTTP verb, for `application/json` response. (using 
  api-gateway module in `samples/modules/api-gateway`)
- Creates lambda `currentTimeLambda` that returns the current time (using lambda module in `module/lambda`)
- Integrates the API Gateway and Lambda via HTTP & deploys the API Gateway (using api-gateway-lambda-integration 
  module in `module/api-gateway-lambda-integration`)

```terraform
provider "aws" {
  region = var.aws_region
}

locals {
  lambda_name = "currentTimeLambda"
  zip_file_name = "/tmp/currentTimeLambda.zip"
  handler_name = "currentTimeLambda.handler"
  rest_api_name = "TimeAPI"
  rest_api_description = "REST API gateway for Time related functions"
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
}

module "lambda_tf_way_api_gateway" {
  source = "../modules/api-gateway"
  lambda_tf_way_rest_api_name = local.rest_api_name
  lambda_tf_way_rest_api_description = local.rest_api_description
}

module "lambda_tf_way_api_gateway_integration" {
  source = "../modules/api-gateway-lambda-integration"

  lambda_tf_way_lambda_function_name = module.current_time_lambda.tf_way_lambda_function_name
  lambda_tf_way_lambda_invoke_arn = module.current_time_lambda.tf_way_lambda_invoke_arn

  lambda_tf_way_rest_api_id = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_id
  lambda_tf_way_rest_api_execution_arn = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_execution_arn

  lambda_tf_way_resource_id = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_root_resource_id

  lambda_tf_way_method = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_method
  lambda_tf_way_method_response_status_code = module.lambda_tf_way_api_gateway.lambda_tf_way_rest_api_method_response_status_code
}

```

##### api-gateway module
- api-gateway module at `samples/modules/api-gateway` creates the `TimeAPI` gateway.
- There are '3' resource definitions in the module.
  1. `aws_api_gateway_rest_api` - Declares the REST API for `TimeAPI`, in API Gateway
  2. `aws_api_gateway_method` - Enables the `TimeAPI` to support 'HTTP GET' in its root resource `/` 
  3. `aws_api_gateway_method_response` - Enables the `GET` to respond `application/json` with status `200`.
> Note: This module has no authorization and this example will be available public. 

##### api-gateway-lambda-integration
- api-gateway-lambda-integration module at `samples/modules/api-gateway-lambda-integration` integrates the 
  `TimeAPI` gateway with `currentTimeLambda`
  
- There are '4' resource definitions in the module.
1. `aws_api_gateway_integration` - Maps the api gateway's rest api & resource ids to the lambda's invoke arn. Here, 
    - The attribute `integration_http_method` is important to understand. It is defined as `POST` as API gateway 
     communicates with Lambda using POST (event if the public API is HTTP GET).
    - Lambda `invoke_arn` is used and not `arn`, for `uri` attribute.
2. `aws_api_gateway_integration_response` - Configured the response for the integration. 
3. `aws_api_gateway_deployment` - Deploys the gateway after the integration is configured.
4. `aws_lambda_permission` - Sets the permission required to invoke the Lambda from API Gateway. This is similar 
     to the S3 invocation of lambda we did earlier.

#### (2) Bundle the lambda
This section will refer to the source `samples/12/currentTimeLambda.js` _(below)_.

##### (2.2) Lambda source
This is a simple lambda that will return the current time.

```javascript
exports.handler =  async (event) => {
  const payload = {
    date: new Date()
  };
  return JSON.stringify(payload);
};
```

##### (2.3) AWS SDK Dependency
Node module `aws-sdk` is not required explicitly on lambda instances. It is available in the lambda environment by default.

##### (2.4) Bundle the source
Let's bundle the lambda source using the following command (or) the script `bundle-lambda.sh` in `samples/12/`.
Run these commands from `samples/12/` folder.

```shell script
#!/bin/sh
zip /tmp/currentTimeLambda.zip currentTimeLambda.js
```

#### (3) Terraform Apply
Now we will run terraform script to create the `currentTimeLambda`. You need to be in the `samples/12` folder
to run the script.

> Note: The `AWS_PROFILE` is configured as `lambda-tf-user`

```shell script
export AWS_PROFILE=lambda-tf-user
terraform init
terraform apply --auto-approve
```

After terraform apply completes, the output on the console should look similar to the one below.

```shell script
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creating...
module.lambda_tf_way_api_gateway.aws_api_gateway_rest_api.lambda_tf_way_rest_api: Creating...
module.lambda_tf_way_api_gateway.aws_api_gateway_rest_api.lambda_tf_way_rest_api: Creation complete after 0s [id=rfozpcqrh1]
module.lambda_tf_way_api_gateway.aws_api_gateway_method.lambda_tf_way_api_gateway_get_method: Creating...
module.lambda_tf_way_api_gateway.aws_api_gateway_method.lambda_tf_way_api_gateway_get_method: Creation complete after 0s [id=agm-rfozpcqrh1-or4grp6i5f-GET]
module.lambda_tf_way_api_gateway.aws_api_gateway_method_response.lambda_tf_way_api_gateway_get_method_response: Creating...
module.lambda_tf_way_api_gateway.aws_api_gateway_method_response.lambda_tf_way_api_gateway_get_method_response: Creation complete after 0s [id=agmr-rfozpcqrh1-or4grp6i5f-GET-200]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Still creating... [10s elapsed]
module.lambda_tf_way_role.aws_iam_role.lambda_tf_way_role: Creation complete after 12s [id=tf_way_lambda_role]
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creating...
module.current_time_lambda.aws_lambda_function.lambda_tf_way_function: Creating...
module.lambda_tf_way_role.aws_iam_role_policy.lambda_tf_way_role_policy: Creation complete after 3s [id=tf_way_lambda_role:tf_way_lambda_role_policy]
module.current_time_lambda.aws_lambda_function.lambda_tf_way_function: Creation complete after 6s [id=currentTimeLambda]
module.lambda_tf_way_api_gateway_integration.aws_lambda_permission.lambda_tf_way_api_gateway_permission: Creating...
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_integration.lambda_tf_way_api_gateway_lambda_get_integration: Creating...
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_integration.lambda_tf_way_api_gateway_lambda_get_integration: Creation complete after 0s [id=agi-rfozpcqrh1-or4grp6i5f-GET]
module.lambda_tf_way_api_gateway_integration.aws_lambda_permission.lambda_tf_way_api_gateway_permission: Creation complete after 0s [id=AllowLambdaExecutionFromAPIGateway]
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_integration_response.lambda_tf_way_api_gateway_lambda_get_integration_response: Creating...
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_integration_response.lambda_tf_way_api_gateway_lambda_get_integration_response: Creation complete after 1s [id=agir-rfozpcqrh1-or4grp6i5f-GET-200]
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_deployment.lambda_tf_way_rest_api_deployment: Creating...
module.lambda_tf_way_api_gateway_integration.aws_api_gateway_deployment.lambda_tf_way_rest_api_deployment: Creation complete after 0s [id=3erc67]

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.

Outputs:

api_gateway_arn = "arn:aws:apigateway:ap-south-1::/restapis/rfozpcqrh1"
api_gateway_execution_arn = "arn:aws:execute-api:ap-south-1:919191919191:rfozpcqrh1"
lambda_arn = "arn:aws:lambda:ap-south-1:919191919191:function:currentTimeLambda"
lambda_name = "currentTimeLambda"
stage_invoke_url = "https://rfozpcqrh1.execute-api.ap-south-1.amazonaws.com/prod"
```

#### (4) Verify API Gateway Integration
Terraform will output `stage_invoke_url` on the console. Access this URL via `curl` or via browser.
You should see the current time, similar to the one below.

```json
{ "date": "2020-12-29T07:43:41.621Z" }
```

#### (5) Teardown
Let's run terraform destroy to delete the infra we created in this tutorial, from `samples/12` folder.

```shell script
export AWS_PROFILE=lambda-tf-user
terraform destroy --auto-approve
```

🏁 **Congrats !** You learnt a key integration in serverless - AWS Lambda and API Gateway 🏁

**Next**: [Teardown](13-teardown.md) 
