# ============================================================================
# EC2 Module - Elastic Compute Cloud
# Cria instância EC2 com Nginx e CloudWatch Agent
# ============================================================================

# Buscar AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group para EC2
resource "aws_security_group" "ec2" {
  name_prefix = "${var.project_name}-${var.environment}-ec2-"
  description = "Security group for EC2 web server"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from anywhere (opcional - considere restringir)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
      Name = "${var.project_name}-${var.environment}-ec2-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role para EC2
resource "aws_iam_role" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Políticas IAM para EC2
resource "aws_iam_role_policy" "ec2_s3_access" {
  name = "${var.project_name}-${var.environment}-ec2-s3-policy"
  role = aws_iam_role.ec2.id

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

# Política para CloudWatch
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Política para SSM (gerenciamento remoto)
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2.name

  tags = var.tags
}

# User Data para configuração inicial
locals {
  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Atualizar sistema
    yum update -y
    
    # Instalar Nginx
    yum install -y nginx
    
    # Instalar CloudWatch Agent
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
    rpm -U ./amazon-cloudwatch-agent.rpm
    
    # Configurar CloudWatch Agent
    cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'CWCONFIG'
    {
      "metrics": {
        "namespace": "${var.project_name}-${var.environment}",
        "metrics_collected": {
          "cpu": {
            "measurement": [
              {"name": "cpu_usage_idle", "rename": "CPU_IDLE", "unit": "Percent"},
              {"name": "cpu_usage_iowait", "rename": "CPU_IOWAIT", "unit": "Percent"},
              "cpu_time_guest"
            ],
            "metrics_collection_interval": 60,
            "totalcpu": false
          },
          "disk": {
            "measurement": [
              {"name": "used_percent", "rename": "DISK_USED", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60,
            "resources": ["*"]
          },
          "mem": {
            "measurement": [
              {"name": "mem_used_percent", "rename": "MEM_USED", "unit": "Percent"}
            ],
            "metrics_collection_interval": 60
          }
        }
      },
      "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/nginx/access.log",
                "log_group_name": "/aws/ec2/${var.project_name}-${var.environment}/nginx",
                "log_stream_name": "{instance_id}/access.log"
              },
              {
                "file_path": "/var/log/nginx/error.log",
                "log_group_name": "/aws/ec2/${var.project_name}-${var.environment}/nginx",
                "log_stream_name": "{instance_id}/error.log"
              }
            ]
          }
        }
      }
    }
    CWCONFIG
    
    # Iniciar CloudWatch Agent
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config \
      -m ec2 \
      -s \
      -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json
    
    # Criar página HTML de exemplo
    cat > /usr/share/nginx/html/index.html <<'HTML'
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cloud Computing - AWS</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                display: flex;
                justify-content: center;
                align-items: center;
                min-height: 100vh;
                margin: 0;
                padding: 20px;
            }
            .container {
                background: white;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                max-width: 800px;
                width: 100%;
            }
            h1 {
                color: #667eea;
                text-align: center;
                margin-bottom: 30px;
            }
            .info-box {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 10px;
                margin: 20px 0;
                border-left: 4px solid #667eea;
            }
            .service {
                display: inline-block;
                background: #667eea;
                color: white;
                padding: 8px 16px;
                margin: 5px;
                border-radius: 20px;
                font-size: 14px;
            }
            .status {
                text-align: center;
                color: #28a745;
                font-weight: bold;
                font-size: 24px;
                margin: 30px 0;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Avaliação 02 - Cloud Computing</h1>
            
            <div class="status">✅ Sistema Online!</div>
            
            <div class="info-box">
                <h3>📋 Informações do Projeto</h3>
                <p><strong>Projeto:</strong> ${var.project_name}</p>
                <p><strong>Ambiente:</strong> ${var.environment}</p>
                <p><strong>Servidor:</strong> EC2 com Nginx</p>
            </div>
            
            <div class="info-box">
                <h3>☁️ Serviços AWS Implementados</h3>
                <div>
                    <span class="service">EC2</span>
                    <span class="service">RDS</span>
                    <span class="service">S3</span>
                    <span class="service">ECS</span>
                    <span class="service">Lambda</span>
                    <span class="service">API Gateway</span>
                    <span class="service">CloudWatch</span>
                </div>
            </div>
            
            <div class="info-box">
                <h3>🔧 Infraestrutura</h3>
                <ul>
                    <li>✅ VPC com subnets públicas e privadas</li>
                    <li>✅ EC2 com Auto Scaling</li>
                    <li>✅ RDS PostgreSQL Multi-AZ</li>
                    <li>✅ S3 com versionamento</li>
                    <li>✅ ECS Fargate</li>
                    <li>✅ Lambda Functions</li>
                    <li>✅ API Gateway REST</li>
                    <li>✅ CloudWatch Monitoring</li>
                    <li>✅ Grafana Dashboards</li>
                </ul>
            </div>
            
            <div class="info-box">
                <h3>📊 Monitoramento</h3>
                <p>Todos os serviços estão sendo monitorados via CloudWatch e Grafana</p>
            </div>
        </div>
    </body>
    </html>
    HTML
    
    # Configurar e iniciar Nginx
    systemctl enable nginx
    systemctl start nginx
    
    # Criar arquivo de status
    echo "EC2 Instance configured successfully at $(date)" > /var/log/instance-setup.log
  EOF
}

# Instância EC2
resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name != "" ? var.key_name : null
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = local.user_data

  monitoring = var.enable_detailed_monitoring

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-web-server"
    }
  )
}

# CloudWatch Log Group para Nginx
resource "aws_cloudwatch_log_group" "nginx" {
  name              = "/aws/ec2/${var.project_name}-${var.environment}/nginx"
  retention_in_days = 7

  tags = var.tags
}



