# ============================================================================
# Monitoring Module - CloudWatch
# Cria dashboard e alarmes para todos os serviços
# ============================================================================

# Dashboard CloudWatch
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # EC2 Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", { stat = "Average", label = "EC2 CPU" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "EC2 - CPU Utilization"
          period  = 300
        }
      },
      # RDS Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", { stat = "Average", label = "RDS CPU" }],
            [".", "DatabaseConnections", { stat = "Average", label = "Connections" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS - Performance"
          period  = 300
        }
      },
      # Lambda Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", { stat = "Sum", label = "Total Invocations" }],
            [".", "Errors", { stat = "Sum", label = "Errors" }],
            [".", "Duration", { stat = "Average", label = "Avg Duration" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Lambda - Invocations & Errors"
          period  = 300
        }
      },
      # ECS Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", { stat = "Average", label = "ECS CPU" }],
            [".", "MemoryUtilization", { stat = "Average", label = "ECS Memory" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "ECS - Resource Usage"
          period  = 300
        }
      },
      # API Gateway Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ApiGateway", "Count", { stat = "Sum", label = "Total Requests" }],
            [".", "4XXError", { stat = "Sum", label = "4XX Errors" }],
            [".", "5XXError", { stat = "Sum", label = "5XX Errors" }],
            [".", "Latency", { stat = "Average", label = "Latency" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "API Gateway - Requests & Errors"
          period  = 300
        }
      },
      # S3 Metrics
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/S3", "NumberOfObjects", { stat = "Average", label = "Object Count" }],
            [".", "BucketSizeBytes", { stat = "Average", label = "Bucket Size" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "S3 - Storage"
          period  = 86400
        }
      }
    ]
  })
}

# ============================================================================
# CloudWatch Alarms
# ============================================================================

# EC2 Alarm - CPU High
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ec2-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "EC2 CPU utilization is too high"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  tags = var.tags
}

# Lambda Alarm - Errors
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count               = length(var.lambda_function_names)
  alarm_name          = "${var.project_name}-${var.environment}-lambda-${var.lambda_function_names[count.index]}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Lambda function ${var.lambda_function_names[count.index]} has too many errors"

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  tags = var.tags
}

# Lambda Alarm - Duration
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  count               = length(var.lambda_function_names)
  alarm_name          = "${var.project_name}-${var.environment}-lambda-${var.lambda_function_names[count.index]}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = "300"
  statistic           = "Average"
  threshold           = "25000"
  alarm_description   = "Lambda function ${var.lambda_function_names[count.index]} duration is too high"

  dimensions = {
    FunctionName = var.lambda_function_names[count.index]
  }

  tags = var.tags
}

# ECS Alarm - CPU High
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ECS CPU utilization is too high"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = var.tags
}

# ECS Alarm - Memory High
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ECS Memory utilization is too high"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  tags = var.tags
}

# ============================================================================
# Log Groups
# ============================================================================

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = var.retention_days

  tags = var.tags
}

# ============================================================================
# Metrics Filter
# ============================================================================

resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "${var.project_name}-${var.environment}-error-count"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "[ERROR]"

  metric_transformation {
    name      = "ErrorCount"
    namespace = "${var.project_name}/${var.environment}"
    value     = "1"
  }
}

# Data source para região atual
data "aws_region" "current" {}



