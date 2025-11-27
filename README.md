# Projeto de Cloud Computing - AWS

## Sobre o Projeto

Este projeto implementa uma arquitetura completa na AWS utilizando Terraform, desenvolvido como parte da avaliação da disciplina de Cloud Computing. A infraestrutura inclui todos os principais serviços AWS: EC2, RDS, S3, ECS, Lambda e API Gateway, com monitoramento integrado via CloudWatch e Grafana.

## Arquitetura

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

## Estrutura do Repositório

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

## Como Usar

### Pré-requisitos

- AWS CLI configurado
- Terraform >= 1.5.0
- Credenciais AWS com permissões adequadas

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

### Testes

Scripts automatizados estão disponíveis para verificação:

```powershell
# Verificar requisitos do projeto
.\VERIFICACAO_SIMPLES.ps1

# Testar serviços AWS
.\TESTAR_SERVICOS_AWS.ps1
```

## Monitoramento

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

## Custos Estimados

A infraestrutura atual tem custo estimado de aproximadamente $70-80/mês na região us-east-1, considerando:
- Instâncias rodando 24/7
- RDS Multi-AZ
- Armazenamento S3
- ECS Fargate
- Lambda e API Gateway (pay-per-use)

Para ambientes de desenvolvimento, recomenda-se destruir a infraestrutura quando não estiver em uso:

```bash
terraform destroy
```

## Documentação Adicional

- **COMO_FUNCIONA_TUDO.md**: Explicação detalhada de cada componente
- **RELATORIO_FINAL.md**: Relatório completo com URLs e configurações
- **ENTREGA_FINAL.md**: Checklist e guia de entrega
- **ROTEIRO_VIDEO.md**: Roteiro para apresentação em vídeo

## Segurança

O projeto implementa várias camadas de segurança:

- **Network**: VPC isolada com subnets públicas/privadas
- **Encryption**: Dados em repouso (RDS, S3) e em trânsito (HTTPS)
- **Access Control**: IAM roles específicas por serviço
- **Secrets**: Credenciais armazenadas no Secrets Manager
- **Monitoring**: Logs centralizados e alertas configurados

## Equipe

[Adicione aqui os nomes dos membros do grupo e RAs]

## Licença

Este projeto foi desenvolvido para fins acadêmicos.

## Contato

Para dúvidas ou sugestões sobre o projeto, entre em contato através do repositório ou das issues do GitHub.
