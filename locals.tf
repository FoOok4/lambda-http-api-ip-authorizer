locals {
  whitelist_authorizer_function = {
    allow_apigateway_statement_id = "${module.authorizer_lambda_function.lambda_function_name}-AllowExecutionFromAPIGateway"
  }
}