variable "environment" {
  type        = string
  description = "Environment of the aws waf"
  nullable    = false
}

variable "nametag" {
  type        = string
  description = "Nametag to identify unique resources"
  nullable    = false
}

variable "api_gateway_execution_arn" {
  description = "Execution arn of the API Gateway triggering the lambda function"
  nullable    = false
}

variable "authorizer_function_env_variables" {
  description = "Environment variables for the lambda function"
  type        = map(string)
  nullable    = false
}

variable "api_gateway_api_id" {
  description = "Brightline core api gateway ID"
  type        = string
  nullable    = false
}