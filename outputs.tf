output "silverlogic_authorizer_id" {
  description = "The id of the lambda authorizer"
  value       = aws_apigatewayv2_authorizer.silverlogic_authorizer.id
}