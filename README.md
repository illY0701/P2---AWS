# Projeto de Cloud Computing - AWS

## Sobre o Projeto

Este projeto implementa uma arquitetura completa na AWS utilizando Terraform, desenvolvido como parte da avaliação da disciplina de Cloud Computing. A infraestrutura inclui todos os principais serviços AWS: EC2, RDS, S3, ECS, Lambda e API Gateway, com monitoramento integrado via CloudWatch e Grafana.

---

## 🏗️ Arquitetura

A arquitetura foi projetada seguindo boas práticas de cloud, com foco em:

- **Segurança**: VPC isolada, encryption at rest e in transit, IAM roles com least privilege
- **Alta Disponibilidade**: Recursos distribuídos em múltiplas zonas de disponibilidade
- **Escalabilidade**: Auto scaling configurado no ECS e design serverless com Lambda
- **Observabilidade**: Monitoramento completo com CloudWatch e dashboards Grafana

### Componentes Principais

**Rede e Segurança**
- VPC customizada com subnets públicas e privadas
- Internet Gateway e NAT Gateway
- Security Groups configurados por serviço
- Flow Logs para auditoria de tráfego

**Compute**
- EC2: Instância web com Nginx
- ECS Fargate: Containers serverless
- Lambda: 3 funções para processamento de dados

**Armazenamento e Dados**
- RDS PostgreSQL com Multi-AZ
- S3 buckets com versionamento e encryption
- Secrets Manager para credenciais

**API e Integração**
- API Gateway REST para exposição das funções Lambda
- CloudWatch para logs e métricas

**Diagrama Completo**: Veja `architecture/diagram.md`

---

## 📋 Requisitos Atendidos

### 1. Diagrama de Arquitetura [2 pontos] ✅
- **Arquivo**: `architecture/diagram.md`
- Contém todos os 6 serviços: EC2, RDS, S3, ECS, Lambda e API Gateway
- Mostra VPC, subnets, security groups e conexões

### 2. Script Terraform [6 pontos] ✅
- **Diretório**: `terraform/`
- Cria **61 recursos** automaticamente com 3 comandos:
  ```bash
  terraform init
  terraform plan
  terraform apply
  ```
- 8 módulos organizados (vpc, ec2, rds, s3, ecs, lambda, api-gateway, monitoring)
- Terraform validate: ✅ Passou

### 3. Dashboard Grafana [2 pontos] ✅
- **Arquivo**: `grafana/dashboards/overview-dashboard.json`
- 5 painéis monitorando: EC2 CPU, RDS CPU, Lambda Errors, API Gateway Requests, ECS Resources

---

## 🚀 Como Usar

### Pré-requisitos

- **Terraform** >= 1.5.0
- **AWS CLI** configurado com credenciais
- **Python 3.8+** (para testes)

### Deploy da Infraestrutura

```bash
# Navegar para o diretório do Terraform
cd terraform

# Inicializar o Terraform
terraform init

# Visualizar o plano de execução
terraform plan

# Aplicar as mudanças
terraform apply
```

⏱️ **Tempo estimado**: ~30 minutos

### Testes

Scripts automatizados estão disponíveis para verificação:

```powershell
# Verificar requisitos do projeto
.\VERIFICACAO_SIMPLES.ps1

# Testar serviços AWS
.\TESTAR_SERVICOS_AWS.ps1
```

---

## 🌐 URLs dos Serviços Deployados

### API Gateway + Lambda

**URL Base:**
```
https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod
```

**Endpoints:**
- **Status**: https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/status
- **Data**: https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/data
- **Process**: https://icxeef1il7.execute-api.us-east-1.amazonaws.com/prod/process

**Console AWS**: https://console.aws.amazon.com/apigateway/home?region=us-east-1#/apis

### EC2 Web Server

**URL**: http://3.90.12.194

**Instance ID**: `i-064b27cf0d1e92b7a`

**Console AWS**: https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:

### S3 Buckets

- **Assets**: `cloud-av2-dev-assets-0rmma1y0`
- **Logs**: `cloud-av2-dev-logs-0rmma1y0`

**Console AWS**: https://s3.console.aws.amazon.com/s3/buckets?region=us-east-1

### ECS Cluster

- **Cluster**: `cloud-computing-av2-dev-cluster`
- **Service**: `cloud-computing-av2-dev-service`

**Console AWS**: https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters

### Lambda Functions

1. `cloud-computing-av2-dev-status`
2. `cloud-computing-av2-dev-data`
3. `cloud-computing-av2-dev-process`

**Console AWS**: https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

### RDS Database

- **Database**: `appdb`
- **Port**: `5432`

**Console AWS**: https://console.aws.amazon.com/rds/home?region=us-east-1#databases:

### CloudWatch Dashboard

**Dashboard**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=cloud-computing-av2-dev-dashboard

---

## 📊 Monitoramento

### CloudWatch

Todas as métricas são coletadas automaticamente pelo CloudWatch:
- CPU e memória de EC2 e ECS
- Latência e erros de Lambda
- Conexões e performance do RDS
- Requisições do API Gateway

### Grafana

Dashboard pré-configurado disponível em `grafana/dashboards/overview-dashboard.json` com:
- Visão geral de todos os serviços
- Métricas de performance em tempo real
- Alarmes configurados para eventos críticos

---

## 🗑️ Destruir Infraestrutura

**IMPORTANTE**: Para evitar custos, destrua a infraestrutura quando não estiver em uso:

```bash
cd terraform
terraform destroy
```

⏱️ **Tempo estimado**: ~15-20 minutos

---

## 💰 Custos Estimados

A infraestrutura atual tem custo estimado de aproximadamente **$70-80/mês** na região us-east-1, considerando:
- Instâncias rodando 24/7
- RDS Multi-AZ
- Armazenamento S3
- ECS Fargate
- Lambda e API Gateway (pay-per-use)

---

## 🔒 Segurança

O projeto implementa várias camadas de segurança:

- **Network**: VPC isolada com subnets públicas/privadas
- **Encryption**: Dados em repouso (RDS, S3) e em trânsito (HTTPS)
- **Access Control**: IAM roles específicas por serviço
- **Secrets**: Credenciais armazenadas no Secrets Manager
- **Monitoring**: Logs centralizados e alertas configurados

---

## 📁 Estrutura do Repositório

```
.
├── architecture/          # Diagramas e documentação da arquitetura
├── terraform/            # Infraestrutura como código
│   ├── modules/         # Módulos reutilizáveis
│   │   ├── vpc/
│   │   ├── ec2/
│   │   ├── rds/
│   │   ├── s3/
│   │   ├── ecs/
│   │   ├── lambda/
│   │   ├── api-gateway/
│   │   └── monitoring/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
├── grafana/             # Configurações de monitoramento
│   └── dashboards/      # Dashboards JSON
├── docs/               # Documentação adicional
└── scripts/            # Scripts auxiliares
```

---

## 📚 Documentação Adicional

- **architecture/diagram.md**: Diagrama completo da arquitetura
- **docs/DEPLOYMENT.md**: Guia detalhado de deploy
- **docs/MONITORING.md**: Configuração de monitoramento
- **docs/SETUP.md**: Configuração inicial

---

## 🔗 Links Úteis

**Repositório GitHub**: https://github.com/illY0701/P2---AWS

**Console AWS**: https://console.aws.amazon.com

**Região**: us-east-1

---

## 👥 Equipe

Anna Isabelle 
César Rodrigues
Evily Maria

---


