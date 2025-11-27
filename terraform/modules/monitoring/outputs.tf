output "dashboard_name" {
  description = "Nome do dashboard CloudWatch"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dashboard_arn" {
  description = "ARN do dashboard CloudWatch"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "log_group_names" {
  description = "Nomes dos log groups criados"
  value       = [aws_cloudwatch_log_group.application.name]
}



