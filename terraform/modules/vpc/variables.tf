variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de zonas de disponibilidade"
  type        = list(string)
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



