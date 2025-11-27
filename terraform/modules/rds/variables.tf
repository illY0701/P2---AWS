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

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos para acessar o RDS"
  type        = list(string)
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
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



