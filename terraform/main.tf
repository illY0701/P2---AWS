# Main Terraform Configuration
# Orquestra todos os módulos da infraestrutura AWS

locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# ============================================================================
# VPC e Networking
# ============================================================================
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

# ============================================================================
# S3 Buckets
# ============================================================================
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
  bucket_prefix = var.s3_bucket_prefix
  tags         = local.common_tags
}

# ============================================================================
# RDS Database
# ============================================================================
module "rds" {
  source = "./modules/rds"

  project_name        = var.project_name
  environment         = var.environment
  db_instance_class   = var.db_instance_class
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  allowed_cidr_blocks = [var.vpc_cidr]
  tags                = local.common_tags

  depends_on = [module.vpc]
}

# ============================================================================
# EC2 Instance
# ============================================================================
module "ec2" {
  source = "./modules/ec2"

  project_name            = var.project_name
  environment             = var.environment
  instance_type           = var.ec2_instance_type
  key_name                = var.ec2_key_name
  vpc_id                  = module.vpc.vpc_id
  public_subnet_id        = module.vpc.public_subnet_ids[0]
  s3_bucket_name          = module.s3.assets_bucket_name
  enable_detailed_monitoring = var.enable_detailed_monitoring
  tags                    = local.common_tags

  depends_on = [module.vpc, module.s3]
}

# ============================================================================
# ECS Cluster
# ============================================================================
module "ecs" {
  source = "./modules/ecs"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  task_cpu           = var.ecs_task_cpu
  task_memory        = var.ecs_task_memory
  desired_count      = var.ecs_desired_count
  db_endpoint        = module.rds.db_endpoint
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  s3_bucket_name     = module.s3.assets_bucket_name
  tags               = local.common_tags

  depends_on = [module.vpc, module.rds, module.s3]
}

# ============================================================================
# Lambda Functions
# ============================================================================
module "lambda" {
  source = "./modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  runtime             = var.lambda_runtime
  timeout             = var.lambda_timeout
  memory_size         = var.lambda_memory
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  s3_bucket_name      = module.s3.assets_bucket_name
  db_endpoint         = module.rds.db_endpoint
  db_name             = var.db_name
  db_username         = var.db_username
  db_password         = var.db_password
  tags                = local.common_tags

  depends_on = [module.vpc, module.s3, module.rds]
}

# ============================================================================
# API Gateway
# ============================================================================
module "api_gateway" {
  source = "./modules/api-gateway"

  project_name             = var.project_name
  environment              = var.environment
  lambda_process_invoke_arn = module.lambda.process_function_invoke_arn
  lambda_process_name      = module.lambda.process_function_name
  lambda_status_invoke_arn  = module.lambda.status_function_invoke_arn
  lambda_status_name       = module.lambda.status_function_name
  lambda_data_invoke_arn    = module.lambda.data_function_invoke_arn
  lambda_data_name         = module.lambda.data_function_name
  tags                     = local.common_tags

  depends_on = [module.lambda]
}

# ============================================================================
# CloudWatch Monitoring
# ============================================================================
module "monitoring" {
  source = "./modules/monitoring"

  project_name             = var.project_name
  environment              = var.environment
  retention_days           = var.cloudwatch_retention_days
  ec2_instance_id          = module.ec2.instance_id
  rds_instance_id          = module.rds.db_instance_id
  ecs_cluster_name         = module.ecs.cluster_name
  ecs_service_name         = module.ecs.service_name
  lambda_function_names    = [
    module.lambda.process_function_name,
    module.lambda.status_function_name,
    module.lambda.data_function_name
  ]
  tags = local.common_tags

  depends_on = [
    module.ec2,
    module.rds,
    module.ecs,
    module.lambda
  ]
}



