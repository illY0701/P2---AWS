variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "retention_days" {
  description = "Dias de retenção para logs"
  type        = number
  default     = 7
}

variable "ec2_instance_id" {
  description = "ID da instância EC2"
  type        = string
}

variable "rds_instance_id" {
  description = "ID da instância RDS"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  type        = string
}

variable "ecs_service_name" {
  description = "Nome do serviço ECS"
  type        = string
}

variable "lambda_function_names" {
  description = "Lista de nomes de funções Lambda"
  type        = list(string)
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



