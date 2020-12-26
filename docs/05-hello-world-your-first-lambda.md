# Hello World - Your First Lambda
This section explains how to deploy and invoke a lambda function using Terraform. Examples here will use 
NodeJS as the runtime. AWS Lambda supports other runtimes (Python, Ruby, Java, Go lang, .net) too. The document here
[AWS Lambda Runtimes](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html) list them in detail.

Terraform Scripts and lambda source code for this section are available in [Chapter 05](../samples/05).

#### (1) Build lambda zip file
This section will bundle the lambda source in a `.zip` file. This will enable the Terraform script to upload the
lambda source zip file for deployment.

##### (1.1) Lambda source
The `helloWorldLambda.js` contains a simple nodejs AWS Lambda. Below snippet shows the same code. When invoked, 
the lambda returns a json payload with the current timestamp and a message.

Note:
- A `handler` module should be exported by the lambda js file.
- The `handler` function is async and takes an `event` object. 
  The `event` object contains the request data from the caller.

```javascript
exports.handler =  async (event) => {
  const payload = {
    date: new Date(),
    message: 'Hello Terraform World'
  };
  return JSON.stringify(payload);
};
```

#### (1.2) Compress the lambda source file
Packaging the `helloWorldLambda.js` file is done using the `zip` command on Mac. From the `samples/05` directory, run the following 
to create a `.zip` file.

```
➜  zip -r /tmp/helloWorldLambda.zip helloWorldLambda.js
```

#### (2) Main Script
The main terraform script for creating the lambda is located in [Chapter 05](../samples/05) directory. This script 
creates the required IAM role for the lambda also.

##### (2.1) Lambda Role

##### (2.2) Lambda Policies

##### (2.3) Lambda

#### (3) Terraform Apply


