locals {
  authorizer_microservice_name     = "whitelist-ip-authorizer-lambda"
  authorizer_lambda_function_alias = "LIVE"
  authorizer_lambda_function_name  = "${var.nametag}-${var.environment}-${local.authorizer_microservice_name}"
  log_retention_in_days            = "30"
}

resource "aws_lambda_alias" "authorizer_lambda_alias" {
  function_name    = module.authorizer_lambda_function.lambda_function_arn
  function_version = module.authorizer_lambda_function.lambda_function_version
  name             = local.authorizer_lambda_function_alias
}


module "authorizer_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.3.0"

  function_name                     = local.authorizer_lambda_function_name
  description                       = "The authorizer whitelist ip-s lambda function"
  handler                           = "lambda_http_api_ip_validation.lambda_handler"
  runtime                           = "python3.9"
  timeout                           = 30
  memory_size                       = 128
  ephemeral_storage_size            = 512
  cloudwatch_logs_retention_in_days = local.log_retention_in_days

  publish               = true
  environment_variables = var.authorizer_function_env_variables

  role_name = "${local.authorizer_lambda_function_name}-role"

  ignore_source_code_hash = true
  create_package          = false

  local_existing_package = "${path.module}/src/authorizer_function.zip"

  attach_policy_statements = true
  policy_statements = {
    lambda_invocation_access = {
      effect = "Allow"
      actions = [
        "lambda:InvokeFunction"
      ]
      resources = ["*"]
    }
    secrets_manager_access = {
      effect = "Allow",
      actions = [
        "secretsmanager:GetSecretValue"
      ],
      resources = ["*"]
    }
  }
}


resource "aws_lambda_permission" "silverlogic_authorizer_lambda_permission" {
  statement_id  = local.whitelist_authorizer_function.allow_apigateway_statement_id
  action        = "lambda:InvokeFunction"
  function_name = module.authorizer_lambda_function.lambda_function_arn
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  qualifier  = aws_lambda_alias.authorizer_lambda_alias.name
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}

resource "aws_apigatewayv2_authorizer" "silverlogic_authorizer" {
  api_id                            = var.api_gateway_api_id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = aws_lambda_alias.authorizer_lambda_alias.invoke_arn
  name                              = "${var.environment}-${var.nametag}-lambda-ips-authorizer"
  authorizer_payload_format_version = "1.0"
  authorizer_result_ttl_in_seconds  = "0"
}