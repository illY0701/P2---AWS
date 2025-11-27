variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs das subnets privadas"
  type        = list(string)
}

variable "task_cpu" {
  description = "CPU para task (256, 512, 1024, etc)"
  type        = string
}

variable "task_memory" {
  description = "Memória para task (512, 1024, 2048, etc)"
  type        = string
}

variable "desired_count" {
  description = "Número desejado de tasks"
  type        = number
}

variable "db_endpoint" {
  description = "Endpoint do banco de dados"
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}

variable "db_username" {
  description = "Username do banco de dados"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password do banco de dados"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



