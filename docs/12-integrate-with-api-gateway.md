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
We will integrate the API Gateway's REST API to backend AWS Lambda function. When the API Gateway's REST API
is accessed as URL (using `curl`), lambda will be invoked by API Gateway and the response from Lambda _(current time)_
will be returned to the user. 

