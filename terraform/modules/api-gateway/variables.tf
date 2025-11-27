variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "lambda_process_name" {
  description = "Nome da função Lambda de processo"
  type        = string
}

variable "lambda_status_name" {
  description = "Nome da função Lambda de status"
  type        = string
}

variable "lambda_data_name" {
  description = "Nome da função Lambda de dados"
  type        = string
}

variable "lambda_process_invoke_arn" {
  description = "Invoke ARN da função Lambda de processo"
  type        = string
}

variable "lambda_status_invoke_arn" {
  description = "Invoke ARN da função Lambda de status"
  type        = string
}

variable "lambda_data_invoke_arn" {
  description = "Invoke ARN da função Lambda de dados"
  type        = string
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
