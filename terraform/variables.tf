variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "cloud-computing-av2"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Responsável pelo projeto"
  type        = string
  default     = "Seu Nome"
}

# VPC
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Zonas de disponibilidade"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# EC2
variable "ec2_instance_type" {
  description = "Tipo de instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Nome do key pair para EC2 (opcional)"
  type        = string
  default     = ""
}

# RDS
variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Username do banco de dados"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Password do banco de dados"
  type        = string
  default     = "ChangeMe123!" # Mude isso!
  sensitive   = true
}

# ECS
variable "ecs_task_cpu" {
  description = "CPU para task ECS (em CPU units)"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memória para task ECS (em MB)"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Número desejado de tasks ECS"
  type        = number
  default     = 2
}

# Lambda
variable "lambda_runtime" {
  description = "Runtime para funções Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Timeout para funções Lambda (em segundos)"
  type        = number
  default     = 30
}

variable "lambda_memory" {
  description = "Memória para funções Lambda (em MB)"
  type        = number
  default     = 256
}

# S3
variable "s3_bucket_prefix" {
  description = "Prefixo para buckets S3"
  type        = string
  default     = "cloud-av2"
}

# Monitoramento
variable "enable_detailed_monitoring" {
  description = "Habilitar monitoramento detalhado"
  type        = bool
  default     = true
}

variable "cloudwatch_retention_days" {
  description = "Dias de retenção dos logs no CloudWatch"
  type        = number
  default     = 7
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais para recursos"
  type        = map(string)
  default     = {}
}



