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

variable "vpc_cidr" {
  description = "VPC CIDR to be allowed on security groups"
  nullable    = false
}

variable "vpc_id" {
  description = "The VPC id to which the API Gateway's security group will be attached"
  nullable    = false
}

variable "subnet_ids" {
  description = "Subnet IDs where the lambda function should run in the VPC"
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