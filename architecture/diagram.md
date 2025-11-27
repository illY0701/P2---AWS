# Diagrama de Arquitetura AWS

## Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Internet Gateway                            │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
┌────────────────────────────────┴────────────────────────────────────┐
│                              VPC                                     │
│                       CIDR: 10.0.0.0/16                             │
│                                                                      │
│  ┌──────────────────────────┐  ┌──────────────────────────────┐   │
│  │   Public Subnet 1a       │  │   Public Subnet 1b           │   │
│  │   CIDR: 10.0.1.0/24      │  │   CIDR: 10.0.2.0/24          │   │
│  │                          │  │                              │   │
│  │  ┌────────────────┐      │  │  ┌────────────────┐         │   │
│  │  │  EC2 Instance  │      │  │  │  NAT Gateway   │         │   │
│  │  │  (Web Server)  │      │  │  │                │         │   │
│  │  │  + CloudWatch  │      │  │  └────────────────┘         │   │
│  │  └────────────────┘      │  │                              │   │
│  │         │                │  │                              │   │
│  └─────────┼────────────────┘  └──────────────────────────────┘   │
│            │                                                        │
│            ├─── Application Load Balancer ───────────────┐         │
│            │                                              │         │
│  ┌─────────┴────────────────┐  ┌──────────────────────────┴───┐   │
│  │   Private Subnet 1a      │  │   Private Subnet 1b          │   │
│  │   CIDR: 10.0.11.0/24     │  │   CIDR: 10.0.12.0/24         │   │
│  │                          │  │                              │   │
│  │  ┌────────────────┐      │  │  ┌────────────────┐         │   │
│  │  │  ECS Cluster   │      │  │  │  RDS Instance  │         │   │
│  │  │  + Fargate     │      │  │  │  (PostgreSQL)  │         │   │
│  │  │  + CloudWatch  │      │  │  │  Multi-AZ      │         │   │
│  │  └────────────────┘      │  │  └────────────────┘         │   │
│  │                          │  │                              │   │
│  └──────────────────────────┘  └──────────────────────────────┘   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                         S3 Bucket                                    │
│                   (Static Assets + Logs)                             │
│                     + Versioning                                     │
│                     + Encryption                                     │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                      API Gateway (REST)                              │
│                            │                                         │
│                            ├─── /api/process (POST)                  │
│                            ├─── /api/status (GET)                    │
│                            └─── /api/data (GET)                      │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
┌────────────────────────────┴─────────────────────────────────────────┐
│                      Lambda Functions                                │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  Process     │  │  Status      │  │  Data        │              │
│  │  Function    │  │  Function    │  │  Function    │              │
│  │  + CloudWatch│  │  + CloudWatch│  │  + CloudWatch│              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│         │                  │                  │                      │
│         └──────────────────┴──────────────────┘                      │
│                            │                                         │
└────────────────────────────┼─────────────────────────────────────────┘
                             │
                    ┌────────┴─────────┐
                    │                  │
                    ▼                  ▼
           ┌─────────────────┐  ┌──────────────┐
           │    S3 Bucket    │  │  RDS (Read)  │
           │  (Data Storage) │  │              │
           └─────────────────┘  └──────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                      CloudWatch                                      │
│                                                                       │
│  • Logs de todos os serviços (EC2, ECS, Lambda, RDS)                │
│  • Métricas (CPU, Memory, Network, Latency)                         │
│  • Alarms                                                            │
│  • Events                                                            │
└────────────────────────────┬─────────────────────────────────────────┘
                             │
┌────────────────────────────┴─────────────────────────────────────────┐
│                         Grafana                                      │
│                                                                       │
│  • Dashboard Overview                                                │
│  • Dashboard EC2                                                     │
│  • Dashboard RDS                                                     │
│  • Dashboard ECS                                                     │
│  • Dashboard Lambda                                                  │
└──────────────────────────────────────────────────────────────────────┘
```

## Fluxo de Dados

### 1. Fluxo Web (EC2 + ECS)
```
Usuário → Internet Gateway → ALB → EC2/ECS → RDS
                                   └→ S3 (Assets)
```

### 2. Fluxo API (Serverless)
```
Cliente → API Gateway → Lambda → RDS
                              └→ S3
```

### 3. Fluxo de Monitoramento
```
Todos os Serviços → CloudWatch → Grafana → Dashboard
```

## Componentes Detalhados

### VPC (Virtual Private Cloud)
- **CIDR**: 10.0.0.0/16
- **Subnets Públicas**: 2 (Multi-AZ)
- **Subnets Privadas**: 2 (Multi-AZ)
- **Internet Gateway**: 1
- **NAT Gateway**: 1

### EC2
- **Tipo**: t3.micro
- **AMI**: Amazon Linux 2023
- **Security Group**: HTTP (80), HTTPS (443)
- **User Data**: Instalação automática de Nginx + CloudWatch Agent

### RDS
- **Engine**: PostgreSQL 15
- **Tipo**: db.t3.micro
- **Multi-AZ**: Sim
- **Backup**: Automático (7 dias)
- **Encryption**: Sim

### S3
- **Buckets**: 2 (assets e logs)
- **Versioning**: Habilitado
- **Encryption**: AES-256
- **Lifecycle**: Transição para Glacier após 90 dias

### ECS
- **Launch Type**: Fargate
- **CPU**: 256
- **Memory**: 512 MB
- **Auto Scaling**: Sim (2-10 tasks)

### Lambda
- **Runtime**: Python 3.11
- **Memory**: 256 MB
- **Timeout**: 30s
- **Concurrent Executions**: 100

### API Gateway
- **Type**: REST API
- **Stage**: prod
- **Throttling**: 1000 req/s
- **Cache**: Habilitado (5 min)

## Segurança

- ✅ VPC isolada com subnets públicas/privadas
- ✅ Security Groups restritivos
- ✅ NACLs configurados
- ✅ Encryption at rest (RDS, S3)
- ✅ Encryption in transit (TLS/SSL)
- ✅ IAM Roles com least privilege
- ✅ CloudWatch Logs criptografados

## Alta Disponibilidade

- ✅ Multi-AZ deployment (RDS, ECS)
- ✅ Application Load Balancer
- ✅ Auto Scaling habilitado
- ✅ Backups automáticos
- ✅ S3 Cross-Region Replication (opcional)

## Custos Estimados

**Estimativa mensal (região us-east-1):**
- VPC/Networking: ~$5
- EC2 (t3.micro): ~$10
- RDS (db.t3.micro): ~$15
- S3 (100GB): ~$3
- ECS Fargate (2 tasks): ~$20
- Lambda (1M requests): ~$0.20
- API Gateway: ~$3.50
- CloudWatch: ~$5
- **Total aproximado**: ~$61.70/mês

*Nota: Custos podem variar conforme uso real*

## Monitoramento

### Métricas Coletadas

**EC2:**
- CPU Utilization
- Network In/Out
- Disk Read/Write
- Memory Usage (CloudWatch Agent)

**RDS:**
- CPU Utilization
- Database Connections
- Read/Write Latency
- Free Storage Space

**ECS:**
- CPU Utilization
- Memory Utilization
- Running Task Count

**Lambda:**
- Invocations
- Duration
- Errors
- Throttles

**S3:**
- Bucket Size
- Number of Objects
- All Requests

## Melhorias Futuras

- [ ] Implementar WAF (Web Application Firewall)
- [ ] Adicionar Route53 para DNS
- [ ] Implementar CloudFront (CDN)
- [ ] Adicionar ElastiCache (Redis)
- [ ] Implementar CI/CD com CodePipeline
- [ ] Adicionar AWS Backup centralizado
- [ ] Implementar AWS Config para compliance



