# ============================================================================
# API Gateway Module - REST API
# Cria API Gateway REST com integração Lambda
# ============================================================================

resource "aws_api_gateway_account" "main" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "${var.project_name}-${var.environment}-apigw-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# REST API
resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "API Gateway for ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# ============================================================================
# Resource: /process (POST)
# ============================================================================

resource "aws_api_gateway_resource" "process" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "process"
}

resource "aws_api_gateway_method" "process_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.process.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "process" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.process.id
  http_method             = aws_api_gateway_method.process_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_process_invoke_arn
}

resource "aws_lambda_permission" "process" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_process_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ============================================================================
# Resource: /status (GET)
# ============================================================================

resource "aws_api_gateway_resource" "status" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "status"
}

resource "aws_api_gateway_method" "status_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.status.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "status" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.status.id
  http_method             = aws_api_gateway_method.status_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_status_invoke_arn
}

resource "aws_lambda_permission" "status" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_status_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ============================================================================
# Resource: /data (GET)
# ============================================================================

resource "aws_api_gateway_resource" "data" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "data_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.data.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "data" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.data.id
  http_method             = aws_api_gateway_method.data_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_data_invoke_arn
}

resource "aws_lambda_permission" "data" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_data_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# ============================================================================
# CORS para todos os recursos
# ============================================================================

# CORS /process
resource "aws_api_gateway_method" "process_options" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.process.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "process_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.process.id
  http_method = aws_api_gateway_method.process_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "process_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.process.id
  http_method = aws_api_gateway_method.process_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "process_options" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.process.id
  http_method = aws_api_gateway_method.process_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.process_options]
}

# ============================================================================
# Deploy
# ============================================================================

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.process.id,
      aws_api_gateway_method.process_post.id,
      aws_api_gateway_integration.process.id,
      aws_api_gateway_resource.status.id,
      aws_api_gateway_method.status_get.id,
      aws_api_gateway_integration.status.id,
      aws_api_gateway_resource.data.id,
      aws_api_gateway_method.data_get.id,
      aws_api_gateway_integration.data.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.process,
    aws_api_gateway_integration.status,
    aws_api_gateway_integration.data,
  ]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = "prod"

  depends_on = [aws_api_gateway_account.main]

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      caller         = "$context.identity.caller"
      user           = "$context.identity.user"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
      protocol       = "$context.protocol"
      responseLength = "$context.responseLength"
    })
  }

  xray_tracing_enabled = true

  tags = var.tags
}

# CloudWatch Log Group para API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api-gateway/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = var.tags
}

# Configurações de throttling
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}



