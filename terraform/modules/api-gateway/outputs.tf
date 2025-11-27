output "api_id" {
  description = "ID da API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "api_arn" {
  description = "ARN da API Gateway"
  value       = aws_api_gateway_rest_api.main.arn
}

output "api_url" {
  description = "URL da API Gateway"
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "api_endpoint" {
  description = "Endpoint da API Gateway"
  value       = aws_api_gateway_rest_api.main.execution_arn
}



