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

variable "runtime" {
  description = "Runtime da função Lambda"
  type        = string
}

variable "timeout" {
  description = "Timeout da função Lambda em segundos"
  type        = number
}

variable "memory_size" {
  description = "Memória da função Lambda em MB"
  type        = number
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
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

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



