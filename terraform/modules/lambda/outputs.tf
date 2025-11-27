output "process_function_arn" {
  description = "ARN da função Lambda de processo"
  value       = aws_lambda_function.process.arn
}

output "process_function_invoke_arn" {
  description = "Invoke ARN da função Lambda de processo"
  value       = aws_lambda_function.process.invoke_arn
}

output "process_function_name" {
  description = "Nome da função Lambda de processo"
  value       = aws_lambda_function.process.function_name
}

output "status_function_arn" {
  description = "ARN da função Lambda de status"
  value       = aws_lambda_function.status.arn
}

output "status_function_invoke_arn" {
  description = "Invoke ARN da função Lambda de status"
  value       = aws_lambda_function.status.invoke_arn
}

output "status_function_name" {
  description = "Nome da função Lambda de status"
  value       = aws_lambda_function.status.function_name
}

output "data_function_arn" {
  description = "ARN da função Lambda de dados"
  value       = aws_lambda_function.data.arn
}

output "data_function_invoke_arn" {
  description = "Invoke ARN da função Lambda de dados"
  value       = aws_lambda_function.data.invoke_arn
}

output "data_function_name" {
  description = "Nome da função Lambda de dados"
  value       = aws_lambda_function.data.function_name
}
