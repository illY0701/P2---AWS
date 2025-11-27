# ============================================================================
# Lambda Module - Serverless Functions
# Cria funções Lambda com VPC, CloudWatch e variáveis de ambiente
# ============================================================================

# Security Group para Lambda
resource "aws_security_group" "lambda" {
  name_prefix = "${var.project_name}-${var.environment}-lambda-"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-lambda-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role para Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Políticas básicas para Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Política para acesso ao S3
resource "aws_iam_role_policy" "lambda_s3" {
  name = "${var.project_name}-${var.environment}-lambda-s3-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "lambda_process" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-process"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_status" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-status"
  retention_in_days = 7
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "lambda_data" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-data"
  retention_in_days = 7
  tags              = var.tags
}

# Código Lambda - Process Function
data "archive_file" "lambda_process" {
  type        = "zip"
  output_path = "${path.module}/lambda_process.zip"

  source {
    content  = file("${path.module}/functions/process.py")
    filename = "index.py"
  }
}

# Código Lambda - Status Function
data "archive_file" "lambda_status" {
  type        = "zip"
  output_path = "${path.module}/lambda_status.zip"

  source {
    content  = file("${path.module}/functions/status.py")
    filename = "index.py"
  }
}

# Código Lambda - Data Function
data "archive_file" "lambda_data" {
  type        = "zip"
  output_path = "${path.module}/lambda_data.zip"

  source {
    content  = file("${path.module}/functions/data.py")
    filename = "index.py"
  }
}

# Lambda Function - Process
resource "aws_lambda_function" "process" {
  filename         = data.archive_file.lambda_process.output_path
  function_name    = "${var.project_name}-${var.environment}-process"
  role             = aws_iam_role.lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_process.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ENVIRONMENT   = var.environment
      DB_HOST       = split(":", var.db_endpoint)[0]
      DB_NAME       = var.db_name
      DB_USERNAME   = var.db_username
      DB_PASSWORD   = var.db_password
      S3_BUCKET     = var.s3_bucket_name
      PROJECT_NAME  = var.project_name
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-process-function"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_process,
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc
  ]
}

# Lambda Function - Status
resource "aws_lambda_function" "status" {
  filename         = data.archive_file.lambda_status.output_path
  function_name    = "${var.project_name}-${var.environment}-status"
  role             = aws_iam_role.lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_status.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ENVIRONMENT  = var.environment
      PROJECT_NAME = var.project_name
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-status-function"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_status,
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc
  ]
}

# Lambda Function - Data
resource "aws_lambda_function" "data" {
  filename         = data.archive_file.lambda_data.output_path
  function_name    = "${var.project_name}-${var.environment}-data"
  role             = aws_iam_role.lambda.arn
  handler          = "index.lambda_handler"
  source_code_hash = data.archive_file.lambda_data.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  environment {
    variables = {
      ENVIRONMENT   = var.environment
      DB_HOST       = split(":", var.db_endpoint)[0]
      DB_NAME       = var.db_name
      S3_BUCKET     = var.s3_bucket_name
      PROJECT_NAME  = var.project_name
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-data-function"
    }
  )

  depends_on = [
    aws_cloudwatch_log_group.lambda_data,
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc
  ]
}



