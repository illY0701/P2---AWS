# ============================================================================
# Outputs principais do projeto
# ============================================================================

output "project_info" {
  description = "Informações gerais do projeto"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region
  }
}

# VPC Outputs
output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

# EC2 Outputs
output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = module.ec2.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = module.ec2.public_dns
}

output "ec2_web_url" {
  description = "URL para acessar a aplicação web no EC2"
  value       = "http://${module.ec2.public_ip}"
}

# RDS Outputs
output "rds_endpoint" {
  description = "Endpoint do banco de dados RDS"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "Nome do banco de dados"
  value       = module.rds.db_name
}

output "rds_port" {
  description = "Porta do banco de dados"
  value       = module.rds.db_port
}

# S3 Outputs
output "s3_assets_bucket_name" {
  description = "Nome do bucket S3 para assets"
  value       = module.s3.assets_bucket_name
}

output "s3_assets_bucket_arn" {
  description = "ARN do bucket S3 para assets"
  value       = module.s3.assets_bucket_arn
}

output "s3_logs_bucket_name" {
  description = "Nome do bucket S3 para logs"
  value       = module.s3.logs_bucket_name
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = module.ecs.service_name
}

# Lambda Outputs
output "lambda_process_function_name" {
  description = "Nome da função Lambda de processamento"
  value       = module.lambda.process_function_name
}

output "lambda_status_function_name" {
  description = "Nome da função Lambda de status"
  value       = module.lambda.status_function_name
}

output "lambda_data_function_name" {
  description = "Nome da função Lambda de dados"
  value       = module.lambda.data_function_name
}

# API Gateway Outputs
output "api_gateway_url" {
  description = "URL base da API Gateway"
  value       = module.api_gateway.api_url
}

output "api_gateway_id" {
  description = "ID da API Gateway"
  value       = module.api_gateway.api_id
}

output "api_endpoints" {
  description = "Endpoints disponíveis da API"
  value = {
    process = "${module.api_gateway.api_url}/process"
    status  = "${module.api_gateway.api_url}/status"
    data    = "${module.api_gateway.api_url}/data"
  }
}

# CloudWatch Outputs
output "cloudwatch_log_groups" {
  description = "Log groups criados no CloudWatch"
  value       = module.monitoring.log_group_names
}

output "cloudwatch_dashboard_url" {
  description = "URL do dashboard CloudWatch"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.monitoring.dashboard_name}"
}

# ============================================================================
# Resumo de Conexão
# ============================================================================
output "connection_summary" {
  description = "Resumo de como conectar nos serviços"
  sensitive   = true
  value = <<-EOT
  
  ═══════════════════════════════════════════════════════════════════
  📋 RESUMO DE ACESSO AOS SERVIÇOS
  ═══════════════════════════════════════════════════════════════════
  
  🌐 Aplicação Web (EC2):
     URL: http://${module.ec2.public_ip}
  
  🔌 API Gateway:
     Base URL: ${module.api_gateway.api_url}
     Endpoints:
       - POST ${module.api_gateway.api_url}/process
       - GET  ${module.api_gateway.api_url}/status
       - GET  ${module.api_gateway.api_url}/data
  
  🗄️  RDS PostgreSQL:
     Host: ${split(":", module.rds.db_endpoint)[0]}
     Port: 5432
     Database: ${module.rds.db_name}
     
  📦 S3 Buckets:
     Assets: ${module.s3.assets_bucket_name}
     Logs: ${module.s3.logs_bucket_name}
  
  🐳 ECS Cluster:
     Name: ${module.ecs.cluster_name}
     Service: ${module.ecs.service_name}
  
  ⚡ Lambda Functions:
     - ${module.lambda.process_function_name}
     - ${module.lambda.status_function_name}
     - ${module.lambda.data_function_name}
  
  📊 CloudWatch Dashboard:
     ${module.monitoring.dashboard_name}
  
  ═══════════════════════════════════════════════════════════════════
  
  Para testar a API:
  
  curl -X POST ${module.api_gateway.api_url}/process \
    -H "Content-Type: application/json" \
    -d '{"message":"Hello from API"}'
  
  curl ${module.api_gateway.api_url}/status
  
  curl ${module.api_gateway.api_url}/data
  
  ═══════════════════════════════════════════════════════════════════
  EOT
}

# Output para facilitar testes
output "test_commands" {
  description = "Comandos para testar a infraestrutura"
  value = {
    test_ec2        = "curl http://${module.ec2.public_ip}"
    test_api_status = "curl ${module.api_gateway.api_url}/status"
    test_api_data   = "curl ${module.api_gateway.api_url}/data"
    test_s3_list    = "aws s3 ls s3://${module.s3.assets_bucket_name}/"
    test_ecs_tasks  = "aws ecs list-tasks --cluster ${module.ecs.cluster_name}"
  }
}



