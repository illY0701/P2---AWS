# Guia de Deploy

## 🚀 Deploy Rápido

### Opção 1: Script Automatizado (Recomendado)
```bash
bash scripts/deploy.sh
```

O script automaticamente:
1. ✅ Verifica pré-requisitos
2. ✅ Valida credenciais AWS
3. ✅ Inicializa Terraform
4. ✅ Valida configurações
5. ✅ Cria plano de execução
6. ✅ Aplica infraestrutura
7. ✅ Exibe resumo e endpoints

### Opção 2: Deploy Manual
```bash
cd terraform

# 1. Inicializar Terraform
terraform init

# 2. Validar configuração
terraform validate

# 3. Criar plano
terraform plan -out=tfplan

# 4. Revisar plano
terraform show tfplan

# 5. Aplicar
terraform apply tfplan

# 6. Ver outputs
terraform output
```

## ⏱️ Tempo Estimado de Deploy

| Componente | Tempo | Descrição |
|------------|-------|-----------|
| VPC e Networking | 2-3 min | Criação de VPC, subnets, IGW, NAT |
| S3 Buckets | 1 min | Criação de buckets |
| EC2 Instance | 2-3 min | Lançamento e inicialização |
| RDS | 10-15 min | ⏰ **Mais demorado** |
| ECS Cluster | 3-5 min | Cluster e tasks |
| Lambda Functions | 2-3 min | Deploy de funções |
| API Gateway | 2-3 min | Configuração de APIs |
| CloudWatch | 1-2 min | Logs e dashboards |
| **TOTAL** | **~25-35 min** | Tempo total estimado |

## 📊 Acompanhando o Deploy

### Terminal
```bash
# Acompanhar em tempo real
terraform apply -auto-approve

# Ver logs detalhados
export TF_LOG=DEBUG
terraform apply
```

### Console AWS
Monitore a criação dos recursos em:
1. **VPC Dashboard**: Networking
2. **EC2 Dashboard**: Instâncias e security groups
3. **RDS Dashboard**: Banco de dados
4. **ECS Dashboard**: Clusters e tasks
5. **Lambda**: Funções
6. **API Gateway**: APIs

## ✅ Verificação Pós-Deploy

### 1. Verificar Outputs
```bash
cd terraform
terraform output
```

Você deve ver:
- ✅ VPC ID e CIDR
- ✅ EC2 Public IP
- ✅ RDS Endpoint
- ✅ S3 Bucket names
- ✅ ECS Cluster name
- ✅ API Gateway URL
- ✅ Lambda function names

### 2. Testar Conectividade

#### A. Testar EC2 Web Server
```bash
# Via output
EC2_IP=$(terraform output -raw ec2_public_ip)
curl http://$EC2_IP

# Ou acesse no navegador
http://[EC2_PUBLIC_IP]
```

Deve retornar uma página HTML com informações do projeto.

#### B. Testar API Gateway
```bash
# Get status
API_URL=$(terraform output -raw api_gateway_url)
curl $API_URL/status

# Post data
curl -X POST $API_URL/process \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello from CLI"}'

# Get data
curl $API_URL/data
```

#### C. Verificar S3
```bash
BUCKET=$(terraform output -raw s3_assets_bucket_name)
aws s3 ls s3://$BUCKET/
```

#### D. Verificar RDS
```bash
# Status do RDS
aws rds describe-db-instances \
  --query 'DBInstances[0].[DBInstanceIdentifier,DBInstanceStatus]' \
  --output table
```

#### E. Verificar ECS
```bash
CLUSTER=$(terraform output -raw ecs_cluster_name)
aws ecs describe-clusters --clusters $CLUSTER
```

#### F. Verificar Lambda
```bash
aws lambda list-functions \
  --query 'Functions[*].[FunctionName,Runtime,LastModified]' \
  --output table
```

### 3. Executar Suite de Testes
```bash
# Script shell
bash scripts/test-infrastructure.sh

# Script Python (mais detalhado)
python tests/infrastructure-test.py
```

## 🔄 Deploy de Updates

### Aplicar Mudanças
```bash
cd terraform

# Ver mudanças
terraform plan

# Aplicar mudanças
terraform apply
```

### Atualizar Funções Lambda
```bash
# Após modificar código das funções
cd terraform
terraform taint module.lambda.aws_lambda_function.process
terraform apply
```

### Atualizar ECS Tasks
```bash
# Força nova deployment
aws ecs update-service \
  --cluster [CLUSTER_NAME] \
  --service [SERVICE_NAME] \
  --force-new-deployment
```

## 🛑 Rollback

### Reverter para Estado Anterior
```bash
# Listar versões do state
terraform state list

# Restaurar de backup
cp terraform.tfstate.backup terraform.tfstate
terraform apply
```

### Destruir Recursos Específicos
```bash
# Remover um recurso específico
terraform destroy -target=module.ec2.aws_instance.web
```

## 🗑️ Destruir Infraestrutura

### Opção 1: Script Automatizado
```bash
bash scripts/destroy.sh
```

### Opção 2: Manual
```bash
cd terraform

# Destruir tudo
terraform destroy

# Ou com auto-approve
terraform destroy -auto-approve
```

⚠️ **ATENÇÃO**: Esta ação é irreversível e todos os dados serão perdidos!

## 📝 Logs e Debugging

### Ver Logs do Terraform
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log
terraform apply
```

### Ver Logs da AWS

#### EC2 Logs
```bash
# System log
aws ec2 get-console-output --instance-id [INSTANCE_ID]

# CloudWatch logs
aws logs tail /aws/ec2/[PROJECT]/nginx --follow
```

#### Lambda Logs
```bash
# Últimos logs
aws logs tail /aws/lambda/[FUNCTION_NAME] --follow

# Logs específicos
aws logs filter-log-events \
  --log-group-name /aws/lambda/[FUNCTION_NAME] \
  --start-time $(date -d '1 hour ago' +%s)000
```

#### ECS Logs
```bash
aws logs tail /ecs/[PROJECT] --follow
```

## 🔧 Troubleshooting

### Erro: "Resource already exists"
```bash
# Importar recurso
terraform import aws_instance.web i-1234567890abcdef0

# Ou destruir e recriar
terraform destroy -target=aws_instance.web
terraform apply
```

### Erro: "Insufficient capacity"
```bash
# Trocar tipo de instância
# Em terraform.tfvars
ec2_instance_type = "t3.small"  # em vez de t3.micro
```

### Erro: "Quota exceeded"
```bash
# Verificar quotas
aws service-quotas list-service-quotas \
  --service-code ec2 \
  --query 'Quotas[*].[QuotaName,Value]'

# Solicitar aumento via console AWS
```

### Erro: "Timeout waiting for resource"
```bash
# Aumentar timeout no código Terraform
# Em modules/*/main.tf, adicione:
timeouts {
  create = "60m"
  update = "30m"
  delete = "30m"
}
```

### RDS não fica "available"
- Pode levar até 15-20 minutos
- Verifique no console se há erros
- Verifique se a subnet group está correta

### Lambda VPC timeout
- Verifique se há NAT Gateway
- Confirme que as subnets privadas têm rota para NAT
- Verifique security groups

## 📊 Monitoramento Durante Deploy

```bash
# Watch resources being created
watch -n 5 'terraform show -json | jq ".values.root_module.resources | length"'

# Monitor AWS resources
watch -n 10 'aws ec2 describe-instances --query "Reservations[*].Instances[*].[State.Name,PublicIpAddress]" --output table'
```

## 💰 Estimativa de Custos

Antes de fazer deploy, estime os custos:

```bash
# Usando Infracost (opcional)
brew install infracost
infracost breakdown --path terraform/
```

Custos estimados mensais:
- **Desenvolvimento**: $50-70/mês
- **Produção**: $200-300/mês (com alta disponibilidade)

## 📋 Checklist de Deploy

- [ ] Credenciais AWS configuradas
- [ ] terraform.tfvars editado
- [ ] Senha do banco alterada
- [ ] Budget alerts configurados
- [ ] `terraform init` executado
- [ ] `terraform validate` passou
- [ ] `terraform plan` revisado
- [ ] `terraform apply` concluído
- [ ] Outputs verificados
- [ ] EC2 acessível
- [ ] API Gateway funcionando
- [ ] Testes passando
- [ ] CloudWatch com dados
- [ ] Grafana configurado

## 🎯 Próximos Passos

Após deploy bem-sucedido:
1. Configure o Grafana: [MONITORING.md](./MONITORING.md)
2. Configure alertas no CloudWatch
3. Documente os endpoints para o vídeo
4. Teste todos os serviços
5. Prepare a apresentação

## 📞 Suporte

Se encontrar problemas:
1. Consulte os logs do Terraform
2. Verifique o Console AWS
3. Revise a documentação AWS
4. Verifique os exemplos no código

Lembre-se: A maioria dos erros são de:
- Credenciais/permissões
- Quotas da AWS
- Configurações de rede
- Timeouts (especialmente RDS)



