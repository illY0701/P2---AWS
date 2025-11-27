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

variable "public_subnet_id" {
  description = "ID da subnet pública"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instância EC2"
  type        = string
}

variable "key_name" {
  description = "Nome do key pair (opcional)"
  type        = string
  default     = ""
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3"
  type        = string
}

variable "enable_detailed_monitoring" {
  description = "Habilitar monitoramento detalhado"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



