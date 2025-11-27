output "assets_bucket_name" {
  description = "Nome do bucket de assets"
  value       = aws_s3_bucket.assets.id
}

output "assets_bucket_arn" {
  description = "ARN do bucket de assets"
  value       = aws_s3_bucket.assets.arn
}

output "logs_bucket_name" {
  description = "Nome do bucket de logs"
  value       = aws_s3_bucket.logs.id
}

output "logs_bucket_arn" {
  description = "ARN do bucket de logs"
  value       = aws_s3_bucket.logs.arn
}



