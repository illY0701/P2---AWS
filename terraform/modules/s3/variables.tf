variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "bucket_prefix" {
  description = "Prefixo para os buckets S3"
  type        = string
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}



