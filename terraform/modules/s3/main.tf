# ============================================================================
# S3 Module - Simple Storage Service
# Cria buckets para assets e logs com configurações de segurança
# ============================================================================

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Bucket para Assets (imagens, arquivos estáticos, etc)
resource "aws_s3_bucket" "assets" {
  bucket = "${var.bucket_prefix}-${var.environment}-assets-${random_string.bucket_suffix.result}"

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${var.environment}-assets"
      Purpose = "Application Assets"
    }
  )
}

# Configuração de versionamento para assets
resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia para assets
resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio de acesso público para assets
resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle para assets (transição para Glacier)
resource "aws_s3_bucket_lifecycle_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    id     = "archive-old-assets"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Bucket para Logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.bucket_prefix}-${var.environment}-logs-${random_string.bucket_suffix.result}"

  tags = merge(
    var.tags,
    {
      Name    = "${var.project_name}-${var.environment}-logs"
      Purpose = "Application Logs"
    }
  )
}

# Configuração de versionamento para logs
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Criptografia para logs
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloqueio de acesso público para logs
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle para logs (retenção)
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

# Policy para permitir escrita de logs do ELB/ALB
resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.logs.arn}/*"
      },
      {
        Sid    = "AWSLogDeliveryAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl"
        ]
        Resource = aws_s3_bucket.logs.arn
      }
    ]
  })
}

# Upload de arquivo de exemplo
resource "aws_s3_object" "sample_file" {
  bucket       = aws_s3_bucket.assets.id
  key          = "sample/hello-world.txt"
  content      = "Hello from S3! Deployed by Terraform."
  content_type = "text/plain"

  tags = merge(
    var.tags,
    {
      Name = "Sample File"
    }
  )
}



